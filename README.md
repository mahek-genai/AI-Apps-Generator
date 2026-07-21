
# AI-Apps-Generator

## Enterprise Generative AI Application Builder using Amazon Bedrock and AWS

This project provides a robust and scalable solution for building and deploying enterprise-grade Generative AI applications leveraging the power of Amazon Bedrock and other core AWS services. It offers a streamlined approach to create AI-powered applications, supporting various use cases with configurable knowledge bases, large language models (LLMs), and deployment options.

## Features

-   **Flexible Use Case Deployment**: Supports both **Text-based** and **Agent-based** Generative AI applications.
-   **Knowledge Base Integration**: Seamlessly integrates with Amazon Kendra and Amazon Bedrock Knowledge Bases for Retrieval Augmented Generation (RAG), enabling applications to provide highly accurate and contextually relevant responses.
-   **Configurable LLMs**: Allows selection and integration of various Large Language Models (LLMs) available through Amazon Bedrock or Amazon SageMaker.
-   **Scalable Architecture**: Deploys a serverless architecture using AWS CloudFormation, ensuring high availability, scalability, and cost-effectiveness.
-   **Secure Deployment**: Supports deployment within a new or existing Amazon Virtual Private Cloud (VPC) for enhanced network security and isolation.
-   **User Interface (UI) Deployment**: Optionally deploys a CloudFront-backed user interface for easy interaction with the Generative AI applications.
-   **Conversation Memory**: Incorporates conversation memory capabilities, typically backed by Amazon DynamoDB, to maintain context across user interactions.
-   **Feedback Mechanism**: Includes an optional feedback system to gather user input and continuously improve AI model performance.
-   **Authentication and Authorization**: Leverages Amazon Cognito for robust user authentication and authorization.
-   **Customizable Parameters**: Provides extensive parameters for fine-tuning deployment settings, including VPC configuration, UI deployment, knowledge base specifics, and LLM choices.

## Architecture Overview

The solution is deployed via AWS CloudFormation, orchestrating a suite of AWS services to create a comprehensive Generative AI application environment. Key components include:

-   **Amazon Bedrock**: For access to foundational models and Bedrock Knowledge Bases.
-   **Amazon Kendra**: For intelligent search and RAG capabilities.
-   **AWS Lambda**: Serverless compute for backend logic and API processing.
-   **Amazon API Gateway**: To expose secure and scalable APIs for the AI applications.
-   **Amazon CloudFront**: For content delivery and hosting the optional user interface.
-   **Amazon Cognito**: For managing user identities and access.
-   **Amazon DynamoDB**: For storing conversation history and other application data.
-   **Amazon S3**: For storing deployment artifacts and potentially knowledge base data.

## Getting Started

To deploy your own Enterprise Generative AI Application:

### Prerequisites

-   AWS Account with appropriate permissions.
-   AWS CLI configured.
-   `git` installed.

### Deployment Steps

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/mahek-genai/AI-Apps-Generator.git
    cd AI-Apps-Generator/ai-app-deployer
    ```

2.  **Configure Parameters**: Edit `parameters.json` to customize your deployment. At a minimum, provide an `AdminUserEmail`.

3.  **Execute Deployment Script**:
    ```bash
    ./deploy.sh
    ```
    The script will guide you through the deployment process, including prompting for an email address for notifications and handling large CloudFormation templates via S3 upload.

Upon successful deployment, the CloudFormation outputs will provide the URLs for your deployed UI and API endpoints.
