pipeline {
    agent any
    environment {
        build_number = "${env.BUILD_ID}"
    }

    stages {
        
        stage('getting code from git') {
            steps {
                git branch: 'main', url: 'https://github.com/Ajmal-MP/Maven-Web-Project.git'
            }
        }
        
            
        stage('Sonar analysis') {
            steps {         
                         withSonarQubeEnv(installationName: 'sq1') {
                            sh '''docker run  --rm --name my-maven \
                                    -v /home/ajmal/jenkins_compose/jenkins_configuration/workspace/build:/usr/src/mymaven \
                                    -w /usr/src/mymaven maven  \
                                     mvn  sonar:sonar clean install'''
                         }
                    }            
            
        }            
            
            

        stage('docker image build') {
            steps {
                sh "docker build -t ajmaldocker07/maven-tomcat:1.${build_number} ."
            }
        } 
        
        stage('Dockerhub login') {
            steps {
                 withCredentials([string(credentialsId: 'dockerhubpwd', variable: 'dockerhubpwd')]) {
                    sh "docker login -u ajmaldocker07 -p ${dockerhubpwd}"   
                    }
            }
        }
        
        stage('docker push') {
            steps {
                sh "docker push ajmaldocker07/maven-tomcat:1.${build_number}"
            }
        }
        
        stage('Remove docker image from local') {
            steps {
                sh "docker rmi -f ajmaldocker07/maven-tomcat:1.${build_number}"
            }
        }


        stage('helmChart tag && push to ECR') {
            steps {

                dir('/var/jenkins_home/workspace/build/maven-tomcat-helmchart') {
                    withCredentials([aws(credentialsId: 'ecr-credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    
                    sh """
                        sed -i  "18 s/version: 1.*/version: 1."${build_number}"/" Chart.yaml
                        sed -i  "s/maven-tomcat:1.*/maven-tomcat:1.${build_number}/" values.yaml
                    """  
                    }
                 }
                 
                dir('/var/jenkins_home/workspace/build') {
                    withCredentials([aws(credentialsId: 'ecr-credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        
                        sh "helm package maven-tomcat-helmchart/"
                        sh "aws ecr get-login-password | helm registry login  --username AWS -p \$(aws ecr get-login-password --region ap-northeast-1)  776606234209.dkr.ecr.ap-northeast-1.amazonaws.com"                
                        sh "helm push maven-tomcat-1.${build_number}.tgz oci://776606234209.dkr.ecr.ap-northeast-1.amazonaws.com"  
                        sh "rm maven-tomcat-1.${build_number}.tgz"
                    }
                } 
                
            }
        }
           

    }
    
    post {
		always {
			sh 'docker logout'
		}
	}
        

}