from lxml import html
import rpy2.robjects as robjects
import requests
import math
import time

rcode = "row.names(as.data.frame(available.packages()))"
packages = robjects.r(rcode)

url = "http://www.rdocumentation.org/advanced_search?utf8=%E2%9C%93&package_name="
results_per_page = 20
failed = []
##package_function_dict = dict()
for i, package in enumerate(packages[373:]):
    print i
    r = requests.get(url + package)
    tree = html.fromstring(r.text)
    try:
        ## this will get list containing string "Found <number> results"
        nresults = tree.xpath('//div[@class="span12"]/h4/text()')
        ## [0] to extract string from list, split by spaces, number
        ## of results is element 1
        nresults = float(nresults[0].split()[1])
        ## how many pages do we need to scrape?
        npages = int(math.ceil(nresults/results_per_page))
    except IndexError:
        failed.append(package)
        continue
    fns = []
    for page in range(npages):
        r = requests.get("%s%s&page=%d" % (url, package, page))
        tree = html.fromstring(r.text)
        fns.extend(tree.xpath('//a[@class="function-name"]/text()'))
    package_function_dict[package] = fns
    ## so I don't make the server sad
    time.sleep(1)
    


