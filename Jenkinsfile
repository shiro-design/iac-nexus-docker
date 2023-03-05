pipeline{
    agent any

    tools {
        maven 'maven'   
    }

    enviroment{
        artifactId = readMavenPom().getArtifactId()
        version = readMavenPom().getVersion()
        name = readMavenPom().getName()
        groupId = readMavenPom().getGroupId()

    }
    stages{
        stage('Build'){
            steps{
                sh 'mvn clean install package'
            }
        }
    }
    stage ('Test'){
        steps{
            echo "testing ..."
        }
    }
    stage ('Publish to Nexus'){
        steps {
            script{
            def Nexusrepo = version,endsWith("SNAPSHOT") ? "ShiroLab-Snapshot" : "ShiroLab-Release"
            nexusArtifactUploader artifacts: 
            [[artifactId: "${artifactId}", 
            classifier: '', file: 
            'target/${artifactId}-${version}.war', 
            type: 'war']], 
            credentialsId: 'Git', 
            groupId: "${groupId}", 
            nexusUrl: '17.98.26.0:8081', 
            nexusVersion: 'nexus2', 
            protocol: 'http', 
            repository: "${Nexusrepo}", 
            version: "${version}"
        }
    }

    stage ('Print Enviroment variables'){
        steps{
            echo "Artifact ID is '${artifactId}'"
            echo "Version ID is '${version}'"
            echo "Group ID is '${groupId}'"
            echo "Name ID is '${Name}'"
        }
    }
    stage ('Deploy'){
        steps {
            echo "Deploying ..."
            sshPublisher(publishers:
            [sshPublisherDesc(
                configName: 'Ansible_Controller',
                transfers: [
                    sshTransfer(
                        cleaningRemote: false,
                        execCommand: 'ansible-playbook downloadandDeploy_Docker.yaml -i hosts',
                        execTimeout: 120000
                    )
                ],
                usePromitionTimestamp: false,
                useWorkspaceInPromotion: false,
                verbose:false)
            ])
        }
    }

}