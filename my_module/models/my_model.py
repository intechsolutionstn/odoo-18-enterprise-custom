# -*- coding: utf-8 -*-

from odoo import models, fields, api


class MyModel(models.Model):
    _name = 'my.model'
    _description = 'My Model'
    _order = 'name'

    name = fields.Char(string='Name', required=True)
    description = fields.Text(string='Description')
    active = fields.Boolean(string='Active', default=True)
    date_created = fields.Datetime(string='Date Created', default=fields.Datetime.now)
    user_id = fields.Many2one('res.users', string='Created By', default=lambda self: self.env.user)
    
    @api.model
    def create(self, vals):
        """Override create to add custom logic"""
        result = super(MyModel, self).create(vals)
        # Add any custom logic here
        return result
    
    def write(self, vals):
        """Override write to add custom logic"""
        result = super(MyModel, self).write(vals)
        # Add any custom logic here
        return result

