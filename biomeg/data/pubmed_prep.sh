#!/bin/bash

export PUBMED_DATA_DIR="${PUBMED_DATA_DIR}"
export OUTPUT_JSON_FILENAME="${OUTPUT_JSON_FILENAME}"

# python PubMedDownloader.py --dataset pubmed_baseline --download_loc ${PUBMED_DATA_DIR}
# python PubMedDownloader.py --dataset pubmed_daily_update --download_loc ${PUBMED_DATA_DIR}
# python PubMedDownloader.py --dataset pubmed_fulltext --download_loc ${PUBMED_DATA_DIR}

tar -xzf ${PUBMED_DATA_DIR}/fulltext/comm_use.A-B.xml.tar.gz -C ${PUBMED_DATA_DIR}/fulltext
tar -xzf ${PUBMED_DATA_DIR}/fulltext/comm_use.C-H.xml.tar.gz -C ${PUBMED_DATA_DIR}/fulltext
tar -xzf ${PUBMED_DATA_DIR}/fulltext/comm_use.I-N.xml.tar.gz -C ${PUBMED_DATA_DIR}/fulltext
tar -xzf ${PUBMED_DATA_DIR}/fulltext/comm_use.O-Z.xml.tar.gz -C ${PUBMED_DATA_DIR}/fulltext

python PubMedToJson.py --pubmed_data_dir=$PUBMED_DATA_DIR --json_filename=${OUTPUT_JSON_FILENAME}

python tools/preprocess_data.py \    
	--input /raid/datasets/pubmed_megatron/pubmed_abs_full-comm.json \
	--output-prefix pubmed_abs_full-comm \
	--vocab /raid/datasets/wiki_books/download/google_pretrained_weights/uncased_L-12_H-768_A-12/vocab.txt \
	--dataset-impl mmap \
	--tokenizer-type BertWordPieceLowerCase \
	--split-sentences \
	--workers 40

python tools/preprocess_data.py \
	--input /raid/datasets/pubmed_megatron/pubmed_abs_full-comm.json \
	--output-prefix pubmed_abs_full-comm_cased \
	--vocab /raid/datasets/wiki_books/download/google_pretrained_weights/cased_L-12_H-768_A-12/vocab.txt \
	--dataset-impl mmap \
	--tokenizer-type BertWordPieceUpperCase \
	--split-sentences \
	--workers 40

