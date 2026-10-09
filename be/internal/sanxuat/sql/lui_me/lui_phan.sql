UPDATE production_batch_item SET batch_rolled_back = true WHERE production_batch_id = $1;
