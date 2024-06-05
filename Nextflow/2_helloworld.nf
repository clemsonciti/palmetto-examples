// Define a parameter string
params.str = 'Hello World!'

// Split the parameter or input sequence into chunks of 6 characters
process splitLetters {
        output:
        path 'part_*'

        """
        printf '${params.str}' | split -b 6 - part_
        """
}

// Convert chunk to uppercase
process convertToUpper {
        input:
        path x

        output:
        stdout

        """
        cat $x | tr '[a-z]' '[A-Z]'
        """
}

//workflow definition with pipes
workflow {
        splitLetters | flatten | convertToUpper | view { it.trim() }
}
