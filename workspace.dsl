workspace "Library Architecture v1.0" "Architecture for Library Systems using EC2 Instances" {

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }
        user = person "LIBRARIAN" {
            tags "Amazon Web Services - User"
        }
        
        group "AWS Environment" {
            webApplication = softwareSystem "Library Booking Application" "An AWS hosted website and associated infrastructure to facillitate the loaning and return of books"{
                tags "Amazon Web Services - Cloud"
                user -> this "Performs various tasks"
                
                route53 = container "Route53" {
                    tags "Amazon Web Services - Route 53"
                    user -> this "Translates HTTPS Requests"
                }    
                WAF = container "Web Application Firewall" "Allow or deny traffic based on rulesets" {
                    tags "Amazon Web Services - WAF"
                    route53 -> this "Filters Traffic"
                }
                S3 = container "Headless Web Interface" "Provides front end static website and forms" {
                    tags "Amazon Web Services - Simple Storage Service S3 Bucket"
                    WAF -> this "Filters Traffic"
                }
                dataFireHose = container "Kinesis data firehose" "Sends log data from WAF to S3" {
                    tags "Amazon Web Services - Kinesis Firehose"
                    WAF -> this "Sends log data from WAF to S3"
                }

                group "Other Pertinent Services" {
                    cloudTrail = container "CloudTrail" "Audit log for all AWS system users" {
                        tags "Amazon Web Services - CloudTrail"
                    }
                    cloudFormation = container "CloudFormation" "Infrastructure as code building solution" {
                        tags "Amazon Web Services - CloudFormation"
                    }

                    KMS = container "KMS" "Key Management and Rotation" {
                        tags "Amazon Web Services - Key Management Service"
                    }
                    cloudWatch = container "CloudWatch" "Resource monitoring, alarms and notifications" {
                        tags "Amazon Web Services - CloudWatch"
                    }
                    SNS = container "SNS" "Notification tooling for otehr services" {
                        tags "Amazon Web Services - Simple Notification Service"
                    }
                    SES = container "SES" "SMTP Server and Email configuration" {
                        tags "Amazon Web Services - Simple Email Service"
                    }
                    IAM = container "IAM" "Identity and Access Management" {
                        tags "Amazon Web Services - Identity and Access Management IAM"
                    }
                    Athena = container "Athena" "Log inspection and querying tool" {
                        tags "Amazon Web Services - Athena"
                    }
                }
                logBucket = container "Log Buckets" {
                    tags "Amazon Web Services - Simple Storage Service S3"
                    dataFireHose -> this "Writes to log bucket"
                    cloudTrail -> this "Writes to log bucket"
                    cloudFormation -> this "Writes to log bucket"
                    cloudWatch -> this "Writes to log bucket"
                    Athena -> this "Reads from and queries"
                }
                group "EU West-1" {
                    group "AWS VPC" {
                        ALB = container "Application Load Balancer" "Routes traffic to healthy instances" {
                            tags "Amazon Web Services - WAF"
                            //WAF -> this "Routes allowed traffic"
                        }
                        ASG = container "Auto Scaling Group - Headless Drupal" "Horizontally Scales EC2 instances" {
                            tags "Amazon Web Services - Auto Scaling"
                            ALB -> this "Routes traffic to healthy instances in group"
                        }
                        apiGateway = container "AWS API Gateway" {
                            tags "Amazon Web Services - API Gateway"
                            S3 -> this "Recieves POST data from front end application targeting RESful endpoint"
                            this -> ALB "Provides secure HTTPS endpoints for exposed Drupal REST Endpoints"
                        }
                        REST = container "Drupal REST Endpoints" {
                            tags "Amazon Web Services - API Gateway Endpoint"
                            ASG -> this "Passes and retrieves data from connected services"
                            search = component "Search for book" "Retrieves book data based on input Payload" {
                                tags "Amazon Web Services - API Gateway Endpoint"
                                ASG -> this "Passes and retrieves data from connected service"
                            } 
                            borrow = component "Borrow for book" "Marks a book as loaned out in the database" {
                                tags "Amazon Web Services - API Gateway Endpoint"
                                ASG -> this "Passes and retrieves data from connected service"
                            } 
                            return = component "Return a book" "Marks a book as available out in the database" {
                                tags "Amazon Web Services - API Gateway Endpoint"
                                ASG -> this "Passes and retrieves data from connected service"
                            }
                            issueFines = component "Issue Fines" "Lists overdue books" {
                                tags "Amazon Web Services - API Gateway Endpoint"
                                ASG -> this "Passes and retrieves data from connected service"
                            }
                            emailOverdue = component "Email Overdue" "Emails customers to advise of overdue books" {
                                tags "Amazon Web Services - API Gateway Endpoint"
                                ASG -> this "Passes and retrieves data from connected service"
                                this -> SES "Sends Emails"
                            }
                        }
                    }
                    AuroraV2 = container "AuroraV2" "Auto scaling database cluster" {
                        tags "Amazon Web Services - Aurora MySQL Instance Alternate"
                        REST -> this "Reads From and Writes To"
                        search -> this "Read / Write"
                        borrow -> this "Read / Write"
                        return -> this "Read / Write"
                        issueFines -> this "Read / Write"
                        emailOverdue -> this "Read / Write"
                    }

                }
                
            }
            
        }
    }
    views {
        systemContext webApplication {
            include *
        }
        properties {
            "structurizr.locale" "en-GB"
        }
        container webApplication {
            include *
        }
        component REST {
            include *
        } 
        styles {
            element "Amazon Web Services - Cloud" {
                shape RoundedBox
                background #ffeb99
                color #000000
            }
            element "External API" {
                shape RoundedBox
                background #adebeb
                color #000000
            }
            element "Amazon Web Services - User" {
                background #6193ff
                color #ffffff
            }
            element "Group:AWS Environment" {
                color #ff0000
            }
            element "Group:EU West-1" {
                color #ff0000
            }
            element "Group:AWS VPC" {
                color #17ff36
                background #6193ff
            }
        }
    //theme default
    theme https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
    theme https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
    }
    configuration {
        scope softwaresystem

    }

}