#!/bin/bash

LOGNAME="${1}"

cd /workspace/MegatronLM/

MP_SIZE=1

CHECKPOINT_PATH="${2}"
VOCAB_FILE="${3}"
DATA_PATH="${4}"

BERT_ARGS="--num-layers 24 \
           --hidden-size 1024 \
           --num-attention-heads 16 \
           --seq-length 512 \
           --max-position-embeddings 512 \
           --lr 0.0001 \
           --train-iters 2000000 \
           --min-lr 0.00001 \
           --lr-decay-iters 990000 \
           --warmup 0.01 \
           --batch-size 8 \
           --vocab-file $VOCAB_FILE \
           --split 949,50,1 \
           --fp16"

OUTPUT_ARGS="--log-interval 10 \
             --save-interval 500 \
             --eval-interval 100 \
             --eval-iters 10 \
             --checkpoint-activations"

python pretrain_bert.py \
        $BERT_ARGS \
        $OUTPUT_ARGS \
        --save $CHECKPOINT_PATH \
        --load $CHECKPOINT_PATH \
        --data-path $DATA_PATH \
        --local_rank=${SLURM_LOCALID} \
        --model-parallel-size $MP_SIZE \
        --DDP-impl torch \
        2>&1 | tee bert_pretraining-${LOGNAME}.log
