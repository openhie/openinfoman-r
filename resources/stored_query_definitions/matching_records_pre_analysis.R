# Adopted from Shaun Grannis by OpenInfoMan Team for OpenInfoMan and CSD
# http://github.com/openhie/openinfoman/adapater/r
# 
# Orginal Authorhsip Follows:
#  file: field_metrics.R
#  author and copyright 2012: Shaun Grannis - 
#  last update: 1/22/2014
#
# Purpose: This R function calculates various informational
#   characteristics for each field in an R data frame. The
#   summary helps to assess the amount and distribution of
#   information contained in each field. This assessment
#   helps inform the selection of fields for record linkage
#
# Pre-requisites: This function requires the "entropy"
#   library. This can be loaded by invoking the R command
#   install.packages("entropy"). It also assumes the data
#   file to be loaded is *pipe*-delimited. (not comma)
#
# Output: A table with the following measures for each
#   field in the data frame:
#
#   1.  Field name ("Col")
#   2.  Shannon's entropy ("H")
#   3.  Maximum possible entropy ("Hmax")
#   4.  Percent of possible maximum entropy ("Hmax%")
#   5.  Total unique values ("UqVal")
#   6.  Average frequency for each value ("Favg")
#   7.  Number of nulls ("N")
#   8.  Number of nulls as a percent of total ("N%")
#   9.  Closed-form u-value ("Uval")
#   10. Blocking efficiency - # of pairs formed if field 
#       as the only blocking variable ("pairs")
#   11. log(base10) of value from 10. ("log(pairs)")
#
# Usage:  (one time only) Install the entropy package from
#         R repository. This is done only once for a given
#         machine


library("entropy")

# load data set to be analyzed from a delimited dataset read from stdin

inDataFrame <- read.table(file('stdin'), sep=",", header=T)



field_metrics <- function(df) {

    ####################
    # Initialize data
    ####################
 
    # Number of metrics calculated for each field from the input data frame
    labels <- c("H", "Hmx", "HmxRt", "UqVal", "Favg", "N", "NRt", "Uval", "prs", "log(prs)")
    num_mets <- length(labels)

    # Total records in the input data frame
    trecs <- length(df[[1]]);

    # The number of fields in the input data frame == length(df)
    flds <- length(df)

    ############################
    # Create output data frame
    ############################

    # Create the initial output data frame using the input data frame row names
    # and add the original data frame name to the field names for clarity
    df_in_name <- deparse(substitute(df))
    df_out <- data.frame( row.names = paste(names(df), df_in_name[1], sep=".") )

    # Add the remaining columns to the output data frame
    for ( j in 1:num_mets[1] ) { 

        df_out <- cbind( df_out, c(1:flds[1]) ) 

    }

    # Add field names to output data frame
    names(df_out) <- labels

    ####################
    # Generate Metrics
    ####################

    # Output total records to STDOUT
    #cat("Total Recs,", trecs[1], "\n", sep="")

    # Output header row to STDOUT
    cat("Col,H,Hmax,Hmax%,UqVal,Favg,N,N%,Uval,pairs,log(pairs)\n",sep="")

    for (j in 1:flds[1] ) {

        # Calculate Shannon's entropy (H)
        ent01 <- entropy(table(factor(do.call(paste, c(df[c(j)], sep = ",")))),method="ML",unit="log2")

        # Calculate Unique Values (UqVal)
        uqval <- length( unique(df[[j]]) )

        # Calculate NULLs (N)
        null01 <- length( df[[j]][ df[[j]] == '' ])

        # Calculate Favg
        favg01 <- trecs[1] / uqval[1]

        # Calculate Maximum Entropy
        mxent <- -( (favg01[1] / trecs[1]) * log( favg01[1] / trecs[1])/log(2) ) * uqval

        # Closed-form u-value
        uval01 <- sum((table(factor(df[[j]]))/trecs[1])^2)

        # Potential pairs formed if used as single blocking variable (N * (N-1) ) / 2
	# (ignore null or "N/A" values)
	tab01 <- table( factor( df[[j]][!is.na(df[[j]]) & df[[j]] != ""] ) )
        prs01 <- sum( tab01  *  ( tab01 - 1 ) / 2 )

        ############################
        # Output metrics to SDTOUT
        ############################

        # Output Column Name
        cat( names(df[j]), ",", sep="")

        # Output Shannon's entropy (H)
        cat( ent01[1], "," , sep="")

        # Output maximum entropy (Hmax)
        cat(mxent[1], ",", sep="")

        # Output maximum entropy percent (Hmax%)
        cat(ent01[1] / mxent[1], ",", sep="")

        # Output Unique Values (UqVal)
        cat( uqval[1], ",", sep="")

        # Output Average Frequency (Favg)
        cat( favg01[1], ",", sep="")

        # Output NULLs (N)
        cat( null01[1], ",", sep="" )

        # Output NULL percent (N%)
        cat( null01[1] / trecs[1], ",", sep="" )

        # Output closed-form U-value (Uval)
        cat( uval01[1], ",", sep="")

        # Output pairs formed if used as single blocking variable
        cat(prs01[1], ",", sep="")

        # Output LOG(pairs formed) if used as single blocking variable
        cat(log(prs01[1])/log(10), "\n", sep="")

        #######################################
        # Load metrics into output data frame
        #######################################

        # Output Shannon's entropy (H)
        df_out[j, 1] <- ent01[1]

        # Output maximum entropy (Hmax)
        df_out[j, 2] <- mxent[1]

        # Output maximum entropy percent (HmxRt)
        df_out[j, 3] <- ( ent01[1] / mxent[1] )

        # Output Unique Values (UqVal)
        df_out[j, 4] <- uqval[1]

        # Output Average Frequency (Favg)
        df_out[j, 5] <- favg01[1]

        # Output NULLs (N)
        df_out[j, 6] <- null01[1]

        # Output NULL percent (NRt)
        df_out[j, 7] <- ( null01[1] / trecs[1] )

        # Output closed-form U-value (Uval)
        df_out[j, 8] <- uval01[1]

        # Output pairs formed if used as single blocking variable
        df_out[j, 9] <- prs01[1]

        # Output LOG(pairs formed) if used as single blocking variable
        df_out[j,10] <- ( log(prs01[1]) / log(10) )

    }

    # Return the output data frame
    df_out

}


# evaluate the data in output dataframe

outDataFrame <- field_metrics(inDataFrame)
