from odoo import api, fields, models


class StockPicking(models.Model):
    _inherit = "stock.picking"

    delivery_report_valued = fields.Boolean(
        related="partner_id.delivery_report_valued",
    )

    currency_id = fields.Many2one(
        comodel_name="res.currency",
        compute="_compute_currency_id",
    )
    amount_untaxed = fields.Monetary(
        string="Untaxed Amount",
        store=True,
        compute_sudo=True,
        compute="_compute_amounts",
    )
    amount_tax = fields.Monetary(
        string="Taxes",
        store=True,
        compute_sudo=True,
        compute="_compute_amounts",
    )
    amount_total = fields.Monetary(
        string="Total",
        store=True,
        compute_sudo=True,
        compute="_compute_amounts",
    )

    tax_totals = fields.Binary(compute="_compute_tax_totals", exportable=False)

    @api.depends("move_ids.sale_line_id.order_id.currency_id")
    def _compute_currency_id(self):
        for record in self:
            if record.sale_id:
                record.currency_id = record.sale_id.currency_id
            else:
                record.currency_id = record.company_id.currency_id

    @api.depends("move_ids_without_package.quantity")
    def _compute_amounts(self):
        """Compute the total amounts of the picking."""
        AccountTax = self.env["account.tax"]
        for picking in self:
            order_lines = picking.move_ids_without_package
            base_lines = [
                line._prepare_base_line_for_taxes_computation() for line in order_lines
            ]
            AccountTax._add_tax_details_in_base_lines(base_lines, picking.company_id)
            AccountTax._round_base_lines_tax_details(base_lines, picking.company_id)
            tax_totals = AccountTax._get_tax_totals_summary(
                base_lines=base_lines,
                currency=picking.sale_id.currency_id or picking.company_id.currency_id,
                company=picking.company_id,
            )
            picking.amount_untaxed = tax_totals["base_amount_currency"]
            picking.amount_tax = tax_totals["tax_amount_currency"]
            picking.amount_total = tax_totals["total_amount_currency"]

    @api.depends_context("lang")
    @api.depends("move_ids_without_package.quantity")
    def _compute_tax_totals(self):
        AccountTax = self.env["account.tax"]
        for order in self:
            order_lines = order.move_ids_without_package
            base_lines = [
                line._prepare_base_line_for_taxes_computation() for line in order_lines
            ]
            AccountTax._add_tax_details_in_base_lines(base_lines, order.company_id)
            AccountTax._round_base_lines_tax_details(base_lines, order.company_id)
            order.tax_totals = AccountTax._get_tax_totals_summary(
                base_lines=base_lines,
                currency=order.currency_id or order.company_id.currency_id,
                company=order.company_id,
            )
