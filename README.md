# noodle

[![CI](https://github.com/soupdevsolutions/noodle/actions/workflows/ci.yml/badge.svg)](https://github.com/soupdevsolutions/noodle/actions/workflows/ci.yml)
[![CD](https://github.com/soupdevsolutions/noodle/actions/workflows/cd.yml/badge.svg)](https://github.com/soupdevsolutions/noodle/actions/workflows/cd.yml)

Noodle is a self-hosted platform aimed at open-source developers, where their supporters can contribute small donations. Noodle's mission is to empower developers to continue their valuable work by providing a simple, secure, and user-friendly way to receive financial backing.

## Deploying your own Noodle page

As opposed to similar platforms, Noodle works as a self-hosted web application: you can fork the repository, make any changes you want, and deploy your own version of Noodle.  
This lets you control the frontend, the backend logic, as well as the data flows.  

### Prerequisites

To deploy the platform, you will need:
- A GitHub account
- An AWS account
- A Stripe account with a [live API key](https://docs.stripe.com/keys)
- An S3 bucket in your AWS account to hold the Tofu state
- A registered Route53 domain in your AWS account (the Noodle infrastructure does not currently support registering the domain)

### Deploying for the first time

After you have forked this repository, follow the next steps:

**1. Get some IAM credentials.**  
In your AWS account, create an IAM role that will be used by GitHub Actions to deploy the resources to AWS. The role should be allowed to work with API Gateway, Lambda, DynamoDB, S3, CloudFront, Route53, ACM, and IAM.

**2. Create the GitHub Actions secrets.**  
In your new repository, go to Settings -> Secrets and Variables -> Actions, and create the following 3 secrets:
- AWS_ACCESS_KEY_ID (from your IAM Role)
- AWS_SECRET_ACCESS_KEY (from your IAM Role)
- STRIPE_API_KEY (your live Stripe API key)

**3. Push to the `main` branch**  
Start making changes to your Noodle setup and push them to the `main` branch. This will trigger the CD pipeline, which will deploy all your resources to your AWS account.

### What should you change? (WIP)

To be able to deploy the application, you should change the following values:
- The TF state bucket name from `./infrastructure/main.tf` 
- The app and domain name from `./infrastructure/locals.tf`

Afterwards, you are free to change anything from:
- infrastructure, from the `./infrastructure` directory
- frontend, from the `./public` and `./templates` files
- backend, from the `./src` files
- GitHub Actions workflows, from the `./github/workflows` directory
