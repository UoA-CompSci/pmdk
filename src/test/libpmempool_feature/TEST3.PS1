#
# Copyright 2018, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# libpmempool_feature/TEST3 -- unit test for invalid features
#

. ..\unittest\unittest.ps1

require_test_type medium

require_build_type debug

require_fs_type any

setup
. .\common.ps1

# test single file pool with invalid compat features
expect_normal_exit $PMEMPOOL create obj $POOL
expect_normal_exit $PMEMSPOIL -v $POOL `
	pool_hdr.features.compat=0xfe `
	"pool_hdr.checksum_gen()" >> $LOG

libpmempool_feature_query_abnormal "CKSUM_2K"

# test multipart poolset with invalid incompat features in one of its part
$POOLSET="$DIR\testset"
$POOL=$POOLSET
$TARGET_PART1="$DIR\testfile23"
$TARGET_PART2="$DIR\testfile11"
$PART_SIZE = (convert_to_bytes "10M")
$PART_SIZE_STR = ${PART_SIZE}.toString() + "B" #10MiB

create_poolset $POOLSET `
	${PART_SIZE_STR}:${TARGET_PART2}:x ${PART_SIZE_STR}:$DIR\testfile12:x `
	R ${PART_SIZE_STR}:$DIR\testfile21:x ${PART_SIZE_STR}:$DIR\testfile22:x `
	${PART_SIZE_STR}:${TARGET_PART1}:x

expect_normal_exit $PMEMPOOL create obj $POOLSET
expect_normal_exit $PMEMSPOIL -v $TARGET_PART1 `
	pool_hdr.features.incompat=0xfe `
	"pool_hdr.checksum_gen()" >> $LOG

libpmempool_feature_query_abnormal "CKSUM_2K"

# test invalid rocompat features in first of its part
expect_normal_exit $PMEMSPOIL -v $TARGET_PART2 `
	pool_hdr.features.ro_compat=0xfe `
	"pool_hdr.checksum_gen()" >> $LOG

libpmempool_feature_query_abnormal "CKSUM_2K"

check

pass
