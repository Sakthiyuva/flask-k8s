pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'halogen-acumen-454303-k2'
        REGION = 'us-central1'
        REPO_NAME = 'flask-k8s'
        IMAGE_NAME = 'flask-app'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        FULL_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}"
        LATEST_IMAGE_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"
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
                sh '''
                docker build -t $FULL_IMAGE_PATH .
                docker tag $FULL_IMAGE_PATH $LATEST_IMAGE_PATH
                '''
            }
        }
        
        stage('Push Docker Image to Artifact Registry') {
            steps {
                withCredentials([file(credentialsId: 'f2f40553-8a52-474a-a809-777e96684730', variable: 'GCP_KEY_FILE')]){
                    sh '''
                    gcloud auth activate-service-account --key-file=$GCP_KEY_FILE
                    gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
                    docker push $FULL_IMAGE_PATH
                    docker push $LATEST_IMAGE_PATH
                    
                    # Verify the image was pushed successfully
                    gcloud artifacts docker images list $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME --limit=5
                    '''
                }
            }
        }
        
        stage('Create Image Pull Secret') {
            steps {
                withCredentials([file(credentialsId: 'f2f40553-8a52-474a-a809-777e96684730', variable: 'GCP_KEY_FILE')]){
                    sh '''
                    # Create or update the image pull secret
                    kubectl create secret docker-registry gcr-json-key \
                        --docker-server=$REGION-docker.pkg.dev \
                        --docker-username=_json_key \
                        --docker-password="$(cat $GCP_KEY_FILE)" \
                        --docker-email=service-account@$PROJECT_ID.iam.gserviceaccount.com \
                        --dry-run=client -o yaml | kubectl apply -f -
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                # Use the specific build number for deployment
                sed -i "s|<your-image-url>|$FULL_IMAGE_PATH|g" k8s/deployment.yaml
                
                # Apply the deployment and service
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                
                # Wait for deployment to be ready
                kubectl rollout status deployment/flask-app --timeout=300s
                
                # Show pod status for debugging
                kubectl get pods -l app=flask-app
                kubectl describe pods -l app=flask-app
                '''
            }
        }
    }
    
    post {
        failure {
            sh '''
            echo "Pipeline failed. Checking pod logs..."
            kubectl get pods -l app=flask-app
            kubectl describe pods -l app=flask-app
            '''
        }
    }
}
