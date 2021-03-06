#!/bin/bash
#
# Poor man's deploy script in lack of better infrastructure.
#

DIST=public
TOML_BASE=config.toml
TOML_DEPLOY=config.deploy.toml

NOW=`date +"%Y-%m-%dT%H:%M:%S+02:00"`

cp $TOML_BASE $TOML_DEPLOY

echo "" >> $TOML_DEPLOY
echo "check_external_links = true" >> $TOML_DEPLOY

if ! grep "^check_external_links = true$" $TOML_DEPLOY > /dev/null
then
   echo "Failed to activate 'check_external_links'."
   exit -1
fi

zola -c $TOML_DEPLOY build

# Update deplyment date in sitemap.xml
sed -i -e "s/_NOW_/$NOW/g" $DIST/sitemap.xml


aws s3 cp $DIST s3://cheats.rs/ --recursive
aws cloudfront create-invalidation --distribution-id E3P5E5G4A4QPL8 --paths "/*"
