
# AI-Apps-Generator: Enterprise Generative AI Application Builder

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Built with AWS](https://img.shields.io/badge/Built%20with-AWS-orange.svg)](https://aws.amazon.com/)
[![Amazon Bedrock](https://img.shields.io/badge/Powered%20by-Amazon%20Bedrock-ff9900.svg)](https://aws.amazon.com/bedrock/)

## 🚀 Value Proposition

In today's rapidly evolving digital landscape, enterprises demand agile, secure, and scalable solutions to harness the power of Generative AI. The **AI-Apps-Generator** project delivers precisely that: a robust, CloudFormation-driven framework for rapidly prototyping, deploying, and managing sophisticated Generative AI applications on Amazon Web Services (AWS). This solution empowers organizations to accelerate innovation, reduce time-to-market for AI initiatives, and maintain stringent enterprise-grade security and operational standards.

## ✨ Features at a Glance

-   **Dual Use Case Support**: Seamlessly deploy both **Text-based** conversational AI and advanced **Agent-based** applications, catering to diverse business needs.
-   **Intelligent Knowledge Integration (RAG)**: Leverage **Amazon Kendra** or **Amazon Bedrock Knowledge Bases** for Retrieval Augmented Generation (RAG), ensuring AI responses are grounded in proprietary data, highly accurate, and contextually relevant.
-   **Flexible LLM Orchestration**: Integrate with a wide array of Large Language Models (LLMs) available through **Amazon Bedrock** or **Amazon SageMaker**, providing unparalleled flexibility and future-proofing.
-   **Cloud-Native Scalability**: Built on a serverless AWS architecture, guaranteeing high availability, automatic scaling, and optimized cost-efficiency for production workloads.
-   **Enhanced Security & Isolation**: Deploy applications within new or existing **Amazon Virtual Private Cloud (VPC)** environments, ensuring network isolation and compliance with enterprise security policies.
-   **Intuitive User Interface (UI)**: Optionally deploy a modern, responsive UI via **Amazon CloudFront**, facilitating effortless interaction and adoption of your Generative AI applications.
-   **Persistent Conversation Memory**: Maintain context across user sessions with integrated conversation memory, powered by **Amazon DynamoDB**, for natural and coherent interactions.
-   **Actionable Feedback Mechanism**: Incorporate an optional feedback system to continuously gather user insights, enabling iterative improvement and fine-tuning of AI model performance.
-   **Robust Authentication & Authorization**: Secure your applications with **Amazon Cognito**, providing enterprise-grade user identity management and access control.
-   **Granular Customization**: Extensive CloudFormation parameters allow for precise configuration of VPC settings, UI deployment, knowledge base specifics, LLM choices, and more, adapting to unique operational requirements.

## 🏗️ Architecture Overview

The **AI-Apps-Generator** solution is meticulously engineered using AWS CloudFormation to orchestrate a comprehensive suite of AWS services, creating a resilient and scalable environment for Generative AI applications. The diagram below illustrates the high-level architecture:

![Project Architecture Diagram](https://files.manuscdn.com/user_upload_by_module/session_file/310519663845315632/tbxwqLZXekzvzYTr.png)

### Key Components & Flow:

1.  **Client Interaction**: Business users interact with the application via a web client, which communicates with the backend through secure API endpoints.
2.  **Secure Frontend Hosting**: **Amazon CloudFront** delivers the static web application (UI) hosted on **Amazon S3**, ensuring low-latency access globally.
3.  **API Gateway & Authentication**: **Amazon API Gateway** acts as the secure entry point for all API requests. A **Lambda Custom Authorizer** integrates with **Amazon Cognito** to manage user authentication and authorization, ensuring only authenticated users can access the AI services.
4.  **Policy & Configuration Storage**: **Amazon DynamoDB** stores user policies and use case configurations, including LLM parameters (prompt, temperature, etc.).
5.  **Asynchronous Processing**: For streaming responses and robust handling, requests are routed through **Amazon SQS FIFO Queue** to the **AWS Lambda LangChain Orchestrator**.
6.  **LLM Orchestration**: The **AWS Lambda LangChain Orchestrator** is the core intelligence, managing the interaction with knowledge bases and LLMs. It stores conversation context in **Amazon DynamoDB Session Store**.
7.  **Knowledge Base Integration**: The orchestrator queries either **Amazon Kendra** or **Amazon Bedrock Knowledge Bases** for relevant information, enabling RAG capabilities.
8.  **Generative AI Models**: The orchestrator interacts with **Amazon Bedrock** or **Amazon SageMaker** to invoke the chosen Large Language Models for generating responses.
9.  **Real-time Response Streaming**: Responses are streamed back to the client via **WebSocket integration** through **Amazon API Gateway**.
10. **Monitoring & Feedback**: **Amazon CloudWatch Custom Dashboards** provide comprehensive monitoring. An **AWS Lambda** function processes feedback, storing it in an **Amazon S3 Feedback Store**.
11. **Web Application Firewall (WAF)**: **AWS WAF V2 WebACL** provides an additional layer of security, protecting the API Gateway from common web exploits.

## 🚀 Getting Started

Deploying your own enterprise-grade Generative AI application with AI-Apps-Generator is straightforward.

### Prerequisites

-   An active **AWS Account** with administrative permissions.
-   **AWS Command Line Interface (CLI)** configured and authenticated.
-   **Git** installed on your local machine.

### Deployment Steps

1.  **Clone the Repository**:
    Begin by cloning the project repository to your local development environment:
    ```bash
    git clone https://github.com/mahek-genai/AI-Apps-Generator.git
    cd AI-Apps-Generator/ai-app-deployer
    ```

2.  **Configure Deployment Parameters**:
    Review and modify the `parameters.json` file to align with your specific deployment requirements. Ensure that the `AdminUserEmail` parameter is updated with a valid email address for notifications.

3.  **Execute Deployment Script**:
    Initiate the CloudFormation deployment process using the provided script:
    ```bash
    ./deploy.sh
    ```
    The script will guide you through the deployment, handling the upload of large CloudFormation templates to S3 and prompting for necessary inputs.

Upon successful deployment, the CloudFormation outputs will provide direct URLs to your deployed UI and API endpoints, ready for immediate use.

## 🔒 Security & Compliance

This solution is designed with enterprise security in mind:

-   **IAM Roles & Policies**: Adheres to the principle of least privilege with granular IAM roles for all AWS resources.
-   **Network Isolation**: Supports deployment within a VPC, allowing for private subnet configurations and restricted internet access.
-   **Data Encryption**: Data at rest and in transit is encrypted using AWS native services.
-   **WAF Integration**: Protects against common web vulnerabilities and bot attacks.
-   **Cognito User Management**: Provides secure user authentication and authorization.

## 📄 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For any questions, issues, or feature requests, please open an issue on the [GitHub repository](https://github.com/mahek-genai/AI-Apps-Generator/issues).
