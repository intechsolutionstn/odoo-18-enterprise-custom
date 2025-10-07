# -*- coding: utf-8 -*-
{
    'name': 'My Module',
    'version': '19.0.1.0.0',
    'category': 'Custom',
    'summary': 'A sample Odoo 19 module',
    'description': """
        This is a sample Odoo 19 module that demonstrates:
        - Basic module structure
        - Model creation
        - View definitions
        - Security configuration
    """,
    'author': 'Your Name',
    'website': 'https://www.yourwebsite.com',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/my_model_views.xml',
    ],
    'installable': True,
    'auto_install': False,
    'application': False,
    'license': 'LGPL-3',
}

