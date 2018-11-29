@isTest
public with sharing class MonitoraStatusTest { 
   
   static testMethod void deveriaRetornarPedidoAtualizado(){

      StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
      mock.setStaticResource('respPedido');
      mock.setStatusCode(200);
      mock.setHeader('Content-Type', 'application/json');
      Test.setMock(HttpCalloutMock.class, mock);

      pedidoDigitado__c pedido = new pedidoDigitado__c();
      pedido.Name = '14614144';
      insert pedido;

      List<pedidoDigitado__c> listaPedidos = [select Id, Name, status__c
                                              from pedidoDigitado__c];

      System.assertEquals(1, listaPedidos.size());
      System.assertEquals(null, listaPedidos[0].status__c);

      Test.startTest();
      Database.executeBatch(new MonitoraStatus());
      Test.stopTest();

      listaPedidos = [select Id, Name, status__c
                      from pedidoDigitado__c];

      System.assertEquals('FATURADO', listaPedidos[0].status__c);

     }
}
