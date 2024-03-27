//Example of implicit parallism
process imagecompress {

        module 'r/4.2.2'

        input:
        path x
        path y

        output:
        path "tillman_svd.jpg"

        script:
        """
        Rscript $x $y
        """
}

process imagecompress2 {

        input:
        path x
        path y

        output:
        path "tillman_svd.jpg"

        script:
        """
        Rscript $x $y
        """
}


process pyimagecompress {

        input:
        path x
        path y

        output:
        path "tillman_svdpy.jpg"

        script:
        """
        python3 $x $y
        """
}

process pyimagecompress2 {

        input:
        path x
        path y

        output:
        path "tillman_svdpy.jpg"

        script:
        """
        python3 $x $y
        """
}

workflow{
        def r1 = Channel.fromPath("${baseDir}/scripts/svd.R")
        def r2 = Channel.fromPath("${baseDir}/scripts/svd.py")
        imagecompress(r1, params.pic)
        imagecompress2(r1, params.pic)
        pyimagecompress(r2, params.pic)
        pyimagecompress2(r2, params.pic)
}
