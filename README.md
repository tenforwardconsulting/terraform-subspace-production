# Subspace: production Environment tf module

This terraform module is used as a default, standard, load balanced environment suitable for initial production deploys.  It has a lot of configuration but it also fairly opinionated.


# Load Balancer
The load balancer is tricky.  If you have access to the DNS zone on AWS/Route53, it can be provisioned automatically (if we write this feature):

    lb_domain_name = "my.production.site"
    lb_alternate_names = ["www.production.site", "production.site"]

If not, e.g. if you have to do email or outside DNS validation, you can instead maunally create a cert on AWS and then specify the ARN:

    lb_certificate_arn "aws.arn.whateverexamplethign"

If you do not specify either `lb_domain_name` or `lb_certificate_arn` your load balancer *will not* be created with an HTTPS/TLS target group, it will be HTTP only.
