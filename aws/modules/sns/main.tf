# Docbuilder
resource "aws_sns_topic" "docbuilder_sns_topic" {
  name = "docbuilder-1"
}

resource "aws_sns_topic" "docbuilder_processed_sns_topic" {
  name = "docbuilder-processed"
}

resource "aws_sns_topic" "docbuilder_adhoc_sns_topic" {
  name = "docbuilder-adhoc"
}

resource "aws_sns_topic" "qe_cache_refreshes_sns_topic" {
  name = "qe-cache-refreshes"
}

resource "aws_iam_policy" "docbuilder_publisher_policy" {
  name = "GleanDocbuilderSNSTopicPublisher"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
        ],
        "Resource" : [
          aws_sns_topic.docbuilder_sns_topic.arn,
          aws_sns_topic.docbuilder_processed_sns_topic.arn,
          aws_sns_topic.docbuilder_adhoc_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_sns_topic" "answers_sns_topic" {
  name = "answers"
}

resource "aws_iam_policy" "answers_publisher_policy" {
  name = "GleanAnswersSNSTopicPublisher"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
        ],
        "Resource" : [
          aws_sns_topic.answers_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "answers_subscriber_policy" {
  name = "GleanAnswersSNSTopicSubscriber"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe",
          "sns:Unsubscribe"
        ],
        "Resource" : [
          aws_sns_topic.answers_sns_topic.arn
        ]
      },
      # This statement is for letting the subscribers create and manage their own queues
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_sns_topic" "activities_sns_topic" {
  name = "activities"
}

resource "aws_iam_policy" "activities_publisher_policy" {
  name = "GleanActivitiesSNSTopicPublisher"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
        ],
        "Resource" : [
          aws_sns_topic.activities_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_sns_topic" "salient_terms_sns_topic" {
  name = "salient_terms"
}

resource "aws_iam_policy" "salient_terms_publisher_policy" {
  name = "GleanSalientTermsSNSTopicPublisher"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
        ],
        "Resource" : [
          aws_sns_topic.salient_terms_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "salient_terms_subscriber_policy" {
  name = "GleanSalientTermsSNSTopicSubscriber"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe",
          "sns:Unsubscribe"
        ],
        "Resource" : [
          aws_sns_topic.salient_terms_sns_topic.arn
        ]
      },
      # This statement is for letting the subscribers create and manage their own queues
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_sns_topic" "tools_sns_topic" {
  name = "tools"
}

resource "aws_iam_policy" "tools_publisher_policy" {
  name = "GleanToolsSNSTopicPublisher"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
        ],
        "Resource" : [
          aws_sns_topic.tools_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "tools_subscriber_policy" {
  name = "GleanToolsSNSTopicSubscriber"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe",
          "sns:Unsubscribe"
        ],
        "Resource" : [
          aws_sns_topic.tools_sns_topic.arn
        ]
      },
      # This statement is for letting the subscribers create and manage their own queues
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "qe_cache_refreshes_publisher_subscriber_policy" {
  name = "GleanQECacheRefreshesPublisherSubscriber"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
          "sns:Subscribe",
          "sns:Unsubscribe",
        ],
        "Resource" : [
          aws_sns_topic.qe_cache_refreshes_sns_topic.arn
        ]
      },
      # This statement is for letting the subscribers create and manage their own queues
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_sqs_queue" "docbuilder_sqs_queue" {
  name = "docbuilder-1"
}

resource "aws_sqs_queue" "docbuilder_adhoc_sqs_queue" {
  name = "docbuilder-adhoc"
}

resource "aws_sns_topic_subscription" "docbuilder_sqs_sns_subscription" {
  topic_arn = aws_sns_topic.docbuilder_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.docbuilder_sqs_queue.arn
}

resource "aws_sns_topic_subscription" "docbuilder_adhoc_sqs_sns_subscription" {
  topic_arn = aws_sns_topic.docbuilder_adhoc_sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.docbuilder_adhoc_sqs_queue.arn
}

# TODO (Vaibhav) Allow flink jobs service account to read (and delete) messages from this queue.
resource "aws_sqs_queue_policy" "docbuilder_sns_sqs_policy" {
  queue_url = aws_sqs_queue.docbuilder_sqs_queue.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "DocbuilderSnsSqsPolicy",
    "Statement" : [
      {
        "Sid" : "Allow-SNS-Messages",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "sns.amazonaws.com"
        },
        "Action" : "sqs:SendMessage",
        "Resource" : aws_sqs_queue.docbuilder_sqs_queue.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : aws_sns_topic.docbuilder_sns_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "docbuilder_adhoc_sns_sqs_policy" {
  queue_url = aws_sqs_queue.docbuilder_adhoc_sqs_queue.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "DocbuilderAdhocSnsSqsPolicy",
    "Statement" : [
      {
        "Sid" : "Allow-SNS-Messages",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "sns.amazonaws.com"
        },
        "Action" : "sqs:SendMessage",
        "Resource" : aws_sqs_queue.docbuilder_adhoc_sqs_queue.arn,
        "Condition" : {
          "ArnEquals" : {
            "aws:SourceArn" : aws_sns_topic.docbuilder_adhoc_sns_topic.arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "docbuilder_sqs_reader_policy" {
  name = "GleanDocbuilderSQSReader"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        "Resource" : [
          aws_sqs_queue.docbuilder_sqs_queue.arn,
          aws_sqs_queue.docbuilder_adhoc_sqs_queue.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "docbuilder_subscriber_policy" {
  name = "GleanDocbuilderSNSTopicSubscriber"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe",
          "sns:Unsubscribe"
        ],
        "Resource" : [
          aws_sns_topic.docbuilder_sns_topic.arn,
          aws_sns_topic.docbuilder_processed_sns_topic.arn,
          aws_sns_topic.docbuilder_adhoc_sns_topic.arn
        ]
      },
      # This statement is for letting the subscribers create and manage their own queues
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}
