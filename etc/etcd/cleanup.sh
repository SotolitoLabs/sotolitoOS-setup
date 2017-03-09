#!/bin/bash

/usr/bin/echo "Cleaning wal stuff"
if [ -f /var/lib/etcd/default.etcd/member/wal/* ]; then
	echo "Removing wal files"
	/usr/bin/rm /var/lib/etcd/default.etcd/member/wal/*
fi
