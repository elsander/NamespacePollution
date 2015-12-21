require(testthat)

caseTests <- function(fn = c('isUpperCamel', 'isLowerCamel',
                          'isSnakeCase', 'isDotCase')){
    fn <- match.arg(fn)
    upperCases <- c('UpperCamel',
                    'UpperCAMEL',
                    'Upper09Camel09',
                    'Upper1case2Camel')
    lowerCases <- c('lowerCamel',
                    'lowerCAMEL',
                    'lower09Camel09',
                    'lower1case2Camel')
    snakeCases <- c('snake_case',
                    'Badger_Badger_Badger',
                    'MUSHROOM_MUSHROOM',
                    'badger_Badger',
                    'mushr00m_mushr00')
    dotCases <- c('dot.case',
                  'CAPS.DOTS',
                  'Camel.Dots.Yay')
    ambiguousCases <- c('nocaseatall',
                        'CAPSLOCK',
                        'dots.and_underscores',
                        'Oneword',
                        '890258',
                        'word9012word',
                        'Word90235word',
                        'there-are-dashes',
                        'There-Are-Dashes',
                        'test.',
                        'test..test',
                        'test_',
                        'test__test',
                        '___',
                        '...')
    c('', 'lowerCamel', 'snake_case', 'dot.case')
    if(fn == 'isUpperCamel'){
        trues <- upperCases
        falses <- c(lowerCases, snakeCases, dotCases, ambiguousCases)
    } else {
        if(fn == 'isLowerCamel'){
            trues <- lowerCases
            falses <- c(upperCases, snakeCases, dotCases, ambiguousCases)
        } else {
            if(fn == 'isSnakeCase'){
                trues <- snakeCases
                falses <- c(upperCases, lowerCases, dotCases, ambiguousCases)
            } else {
                trues <- dotCases
                falses <- c(upperCases, lowerCases, snakeCases, ambiguousCases)
            }
        }
    }
    for(case in trues){
        tmp <- tryCatch({
            expect_true(do.call(fn, list(case)))
        }, error = function(cond) {
            print(paste(case, 'is not true'))
        })
    }
    for(case in falses){
        tmp <- tryCatch({
            expect_false(do.call(fn, list(case)))
        }, error = function(cond) {
            print(paste(case, 'is not false'))
        })
    }    
}

############################################################
############################################################

isUpperCamel <- function(myString){
    out <- grepl("^[A-Z]([A-Z0-9]*[a-z][a-z0-9]*[A-Z]|[a-z0-9]*[A-Z][A-Z0-9]*[a-z])[A-Za-z0-9]*$", myString)
    return(out)
}

isLowerCamel <- function(myString){
    out <- grepl("^[a-z]([A-Z0-9]*[a-z][a-z0-9]*[A-Z]|[a-z0-9]*[A-Z][A-Z0-9]*[a-z])[A-Za-z0-9]*$", myString)
    return(out)
}

isSnakeCase <- function(myString){
    out <- grepl("^[a-zA-Z]+[a-zA-Z0-9]*_([a-zA-Z0-9]+_)*[a-zA-Z0-9]+$",
                 myString)
    return(out)
}

isDotCase <- function(myString){
    out <- grepl("^[a-zA-Z]+[a-zA-Z0-9]*\\.([a-zA-Z0-9]+\\.)*[a-zA-Z0-9]+$", perl = TRUE,
                 myString)
    return(out)
}

