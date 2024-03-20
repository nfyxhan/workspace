#!/bin/sh
#
set -e 

product_file=`find /usr/lib/code-server/lib/vscode/ -name product.json`

temp_file=`mktemp /tmp/product.json.XXXXXXXXXXXXXX`
cat $product_file | jq '(.extensionsGallery) |= 
{
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items",
    "controlUrl": "",
    "recommendationsUrl": ""
}
' > $temp_file

mv ${product_file} ${product_file}.bak
mv ${temp_file} ${product_file}