#---------------------------------------------------------------------------------------------#
# Módulo para configurar o Cognito User Pool e User Pool Client
#---------------------------------------------------------------------------------------------#


resource "aws_cognito_user_pool" "main" {
  name                     = var.user_pool_name
  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = var.username_attributes

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = var.email_required

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = var.name_required

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = var.tags
}

resource "aws_cognito_user_pool" "admin" {
  name                     = "${var.user_pool_name}-admins"
  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = var.username_attributes
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_message = "Bem-vindo {username}! Seu CPF foi cadastrado no sistema. Sua senha temporária é {####}."
      email_subject = "Cadastro realizado"
      # AWS requires the SMS invite template to include the {####} placeholder
      # which will be replaced with the temporary password/code when creating the user.
      sms_message = "Bem-vindo {username}! Seu CPF foi cadastrado no sistema. Sua senha temporária é {####}."
    }
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = var.email_required

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    mutable             = true
    required            = var.name_required

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "customer" {
  name         = "${var.user_pool_name}-customer"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret               = var.generate_secret
  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  read_attributes = [
    "email",
    "name",
    "email_verified"
  ]

  write_attributes = [
    "email",
    "name"
  ]

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_user_pool_client" "admin" {
  name         = "${var.user_pool_name}-admin"
  user_pool_id = aws_cognito_user_pool.admin.id

  generate_secret               = var.generate_secret
  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  read_attributes = [
    "email",
    "name",
    "email_verified"
  ]

  write_attributes = [
    "email",
    "name"
  ]

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
}