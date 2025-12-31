# sports

Flutter project for studying.

## Compiling
For Development environment hosted in S3 private bucket:

```bash
flutter build web --debug --build-number <BUILD NUMBER> --build-name=<BUILD NAME> --pwa-strategy=none -v --dart-define=REDIRECT_URI=https://<AWS CLOUDFRONT CDN ID>.cloudfront.net/ --dart-define=COGNITO_CLIENT_ID=<COGNITO CLIENT ID> --dart-define=COGNITO_DOMAIN=<COGNITO DOMAIN PREFIX>.auth.<AWS REGION ID>.amazoncognito.com
```

For a production release replace --debug by --release.

## Running locally
```bash
flutter run -d chrome --web-port 8088 --dart-define=COGNITO_CLIENT_ID=<COGNITO CLIENT ID> --dart-define=COGNITO_DOMAIN=<COGNITO DOMAIN PREFIX>.auth.<AWS REGION ID>.amazoncognito.com --dart-define=REDIRECT_URI=http://localhost:8088/
``` 

## Deployment to S3
A Critical Warning on --debug and S3
Since you are sticking to --debug, please be aware of one proven technical constraint: The flutter build web --debug command uses the Development Compiler (dartdevc). It generates a manifest.json and a series of JavaScript modules.

[!IMPORTANT] Some static hosts (including S3) might fail to serve these modules if they don't have the correct MIME types.
Ensure S3 serves .js files as application/javascript.
Ensure S3 serves .json files as application/json

### Command lines
1. General upload with NO CACHE policy for development.
```bash
aws s3 sync build/web s3://<S3 BUCKET NAME> --delete --cache-control "no-store, must-revalidate"
```

2. Explicitly secure the Content-Type of the executables (Extra security layer)

We use 'cp' with the '--recursive' flag on the same files to force the metadata.
```bash
aws s3 cp s3://<S3 BUCKET NAME> s3://<S3 BUCKET NAME> --recursive --exclude "*" --include "*.js" --content-type "application/javascript" --metadata-directive REPLACE --cache-control "no-store, must-revalidate"
```

```bash
aws s3 cp s3://<S3 BUCKET NAME> s3://<S3 BUCKET NAME> --recursive --exclude "*" --include "*.json" --content-type "application/json" --metadata-directive REPLACE --cache-control "no-store, must-revalidate"
```

## Cloudfront considerations
Configure Error Responses in your CloudFront distribution:

Error Pages Tab > Create Custom Error Response.

HTTP Error Code: 404 (and also for para 403).

Customize Error Response: Yes.

Response Page Path: /index.html.

HTTP Response Code: 200.

CloudFront will always deliver index.html and Flutter will handle the route internally.