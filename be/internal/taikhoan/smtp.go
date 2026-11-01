package taikhoan

import (
	"context"
	"crypto/tls"
	"fmt"
	"net"
	"net/mail"
	"net/smtp"
	"os"
	"strings"
	"time"
)

// SMTPFromEnv đọc cấu hình triển khai PT-7. Thiếu cấu hình đi qua đường suy giảm của Service.
func SMTPFromEnv() Mailer {
	host, from := os.Getenv("BANHCUON_SMTP_HOST"), os.Getenv("BANHCUON_SMTP_FROM")
	if host == "" || from == "" {
		return nil
	}
	port := os.Getenv("BANHCUON_SMTP_PORT")
	if port == "" {
		port = "587"
	}
	return smtpMailer{host, port, from, os.Getenv("BANHCUON_SMTP_USER"), os.Getenv("BANHCUON_SMTP_PASSWORD")}
}

type smtpMailer struct{ host, port, from, user, password string }

func (m smtpMailer) SendPasswordReset(ctx context.Context, email, token string) error {
	return m.send(ctx, email, "Dat lai mat khau", "Ma dat lai mat khau (han 30 phut, dung mot lan):\r\n"+token)
}
func (m smtpMailer) SendEmailVerification(ctx context.Context, email, link string) error {
	return m.send(ctx, email, "Xac nhan Gmail", "Mo link de xac nhan Gmail (han 24 gio, dung mot lan):\r\n"+link)
}
func (m smtpMailer) send(ctx context.Context, email, subject, body string) error {
	from, err := mail.ParseAddress(m.from)
	if err != nil {
		return err
	}
	to, err := mail.ParseAddress(email)
	if err != nil {
		return err
	}
	if strings.ContainsAny(m.from+email, "\r\n") {
		return fmt.Errorf("địa chỉ thư không hợp lệ")
	}
	conn, err := (&net.Dialer{Timeout: 10 * time.Second}).DialContext(ctx, "tcp", net.JoinHostPort(m.host, m.port))
	if err != nil {
		return err
	}
	defer conn.Close()
	deadline := time.Now().Add(15 * time.Second)
	if d, ok := ctx.Deadline(); ok && d.Before(deadline) {
		deadline = d
	}
	if err = conn.SetDeadline(deadline); err != nil {
		return err
	}
	client, err := smtp.NewClient(conn, m.host)
	if err != nil {
		return err
	}
	defer client.Close()
	if err = client.StartTLS(&tls.Config{ServerName: m.host, MinVersion: tls.VersionTLS12}); err != nil {
		return err
	}
	if m.user != "" {
		if err = client.Auth(smtp.PlainAuth("", m.user, m.password, m.host)); err != nil {
			return err
		}
	}
	if err = client.Mail(from.Address); err != nil {
		return err
	}
	if err = client.Rcpt(to.Address); err != nil {
		return err
	}
	w, err := client.Data()
	if err != nil {
		return err
	}
	_, err = fmt.Fprintf(w, "From: %s\r\nTo: %s\r\nSubject: %s\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n%s\r\n", from.String(), to.String(), subject, body)
	if err != nil {
		return err
	}
	if err = w.Close(); err != nil {
		return err
	}
	return client.Quit()
}
