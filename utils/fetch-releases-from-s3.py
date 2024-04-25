import boto3, json
from botocore import UNSIGNED
from botocore.config import Config

s3 = boto3.client('s3', config=Config(signature_version=UNSIGNED))

contents = s3.list_objects_v2(Bucket='overturemaps-us-west-2', Delimiter='/', Prefix='release/')

output = {}

for idx, release in enumerate(sorted(contents.get('CommonPrefixes'), key=lambda x:x.get('Prefix'), reverse = True)):
    path = release.get('Prefix').split('/')[1]
    if idx==0:
        output['latest'] = path
        output['releases'] = []
    output['releases'].append(path)

with open ('releases.json','w') as output_file:
    output_file.write(json.dumps(output, indent=4))
