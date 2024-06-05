process Diversity {

        input:
        path x

        output:
        path "./moving_picture_tutorial"

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table table.qza --p-sampling-depth 1103 --m-metadata-file sample_metadata.tsv --output-dir core-metrics-results
        """
}

process AlphaDiv1 {

        input:
        path x

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/faith_pd_vector.qza --m-metadata-file sample_metadata.tsv --o-visualization core-metrics-results/faith-pd-group-significance.qzv
        """

}

process AlphaDiv2 {

        input:
        path x

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-results/evenness_vector.qza --m-metadata-file sample_metadata.tsv --o-visualization core-metrics-results/evenness-group-significance.qzv
        """

}

process BetaDiv1 {

        input:
        path x

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file sample_metadata.tsv --m-metadata-column body-site --o-visualization core-metrics-results/unweighted-unifrac-body-site-significance.qzv  --p-pairwise
        """
}

process BetaDiv2 {

        input:
        path x

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity beta-group-significance --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza --m-metadata-file sample_metadata.tsv --m-metadata-column subject --o-visualization core-metrics-results/unweighted-unifrac-subject-group-significance.qzv --p-pairwise
        """
}

process AlphaRarFac {

        input:
        path x

        script:
        """
        module load biocontainers
        module load qiime2
        cd $x
        qiime diversity alpha-rarefaction --i-table table.qza --i-phylogeny rooted-tree.qza --p-max-depth 4000 --m-metadata-file sample_metadata.tsv --o-visualization alpha-rarefaction.qzv
        """
}
