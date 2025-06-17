pipeline {
    agent any

    environment {
        PROJECT_ID = 'halogen-acumen-454303-k2'
        REGION = 'us-central1'
        REPO_NAME = 'flask-k8s'
        IMAGE_NAME = 'flask-app'
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"
    }

    stages {
        stage('Clone GitHub Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Sakthiyuva/flask-k8s.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $FULL_IMAGE_PATH .'
            }
        }

        stage('Push Docker Image to Artifact Registry') {
            steps {
                withCredentials([file(credentialsId: 'f2f40553-8a52-474a-a809-777e96684730', variable: 'GCP_KEY_FILE')]){
                sh '''
                gcloud auth activate-service-account --key-file=$GCP_KEY_FILE
                gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
                docker push $FULL_IMAGE_PATH
                '''
                }    
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                sed -i "s|<your-image-url>|$FULL_IMAGE_PATH|g" k8s/deployment.yaml
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

