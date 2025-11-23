# Recurso do Application Registry no AWS Service Catalog
resource "aws_servicecatalogappregistry_application" "app_catalog" {
  name        = var.project_name
  description = var.project_description

  tags = var.project_common_tags
}

# Grupo de associação de atributos para o Application Registry
resource "aws_servicecatalogappregistry_attribute_group" "attribute_group" {
  name        = "${var.project_name}-attributes"
  description = "Grupo de atributos para o projeto ${var.project_name}"

  attributes = jsonencode({
    Project     = var.project_name
  })

  tags = var.project_common_tags
}

# Associação do grupo de atributos ao Application Registry
resource "aws_servicecatalogappregistry_attribute_group_association" "attribute_group_association" {
  application_id = aws_servicecatalogappregistry_application.app_catalog.id
  attribute_group_id = aws_servicecatalogappregistry_attribute_group.attribute_group.id
}