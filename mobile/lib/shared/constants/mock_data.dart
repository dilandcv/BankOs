class MockData {
  MockData._();

  static const userName = 'María González';
  static const tenantName = 'Banco Horizonte';
  static const totalBalance = '\$ 12,450.00';

  static const accounts = [
    {
      'id': 'acc-1',
      'name': 'Cuenta Corriente',
      'number': '**** 4821',
      'currency': 'USD',
      'balance': '\$ 8,250.00',
      'status': 'Activa',
    },
    {
      'id': 'acc-2',
      'name': 'Cuenta de Ahorros',
      'number': '**** 9034',
      'currency': 'USD',
      'balance': '\$ 3,200.00',
      'status': 'Activa',
    },
    {
      'id': 'acc-3',
      'name': 'Cuenta Multimoneda',
      'number': '**** 7710',
      'currency': 'EUR',
      'balance': '€ 920.00',
      'status': 'Activa',
    },
  ];

  static const transactions = [
    {
      'title': 'Depósito recibido',
      'subtitle': 'Cuenta Corriente • Hoy',
      'amount': '+ \$ 500.00',
      'type': 'in',
    },
    {
      'title': 'Transferencia enviada',
      'subtitle': 'A Cuenta Ahorros • Ayer',
      'amount': '- \$ 150.00',
      'type': 'out',
    },
    {
      'title': 'Retiro cajero',
      'subtitle': 'Cuenta Corriente • 10 Nov',
      'amount': '- \$ 80.00',
      'type': 'out',
    },
    {
      'title': 'Pago de nómina',
      'subtitle': 'Cuenta Corriente • 08 Nov',
      'amount': '+ \$ 2,300.00',
      'type': 'in',
    },
  ];
}
