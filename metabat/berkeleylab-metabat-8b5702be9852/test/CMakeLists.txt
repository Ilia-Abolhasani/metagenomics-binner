
set(CTEST_OUTPUT_ON_FAILURE 1)

file(MAKE_DIRECTORY  ${CMAKE_BINARY_DIR}/test-each)
add_test(NAME test_depths
         COMMAND ${CMAKE_BINARY_DIR}/src/jgi_summarize_bam_contig_depths --referenceFasta ${CMAKE_CURRENT_SOURCE_DIR}/contigs.fa --outputDepth contigs_depth.txt ${CMAKE_CURRENT_SOURCE_DIR}/contigs-1000.fastq.bam
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test-each
        )

file(MAKE_DIRECTORY  ${CMAKE_BINARY_DIR}/test-each)
add_test(NAME test_metabat1
         COMMAND ${CMAKE_BINARY_DIR}/src/metabat1 --inFile ${CMAKE_CURRENT_SOURCE_DIR}/contigs.fa --abdFile contigs_depth.txt --outFile metabat1/contigs_bins -v
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test-each
        )

file(MAKE_DIRECTORY  ${CMAKE_BINARY_DIR}/test-each)
add_test(NAME test_metabat2
         COMMAND ${CMAKE_BINARY_DIR}/src/metabat2 --inFile ${CMAKE_CURRENT_SOURCE_DIR}/contigs.fa --abdFile contigs_depth.txt --outFile metabat2/contigs_bins -v
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test-each
        )

file(MAKE_DIRECTORY  ${CMAKE_BINARY_DIR}/test-runMetaBat)
add_test(NAME runMetaBat.sh
         COMMAND  ${CMAKE_SOURCE_DIR}/runMetaBat.sh ${CMAKE_CURRENT_SOURCE_DIR}/contigs.fa ${CMAKE_CURRENT_SOURCE_DIR}/contigs-1000.fastq.bam
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test-runMetaBat
        )
