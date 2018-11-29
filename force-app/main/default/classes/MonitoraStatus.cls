global with sharing class MonitoraStatus implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts
{
    global Database.Querylocator start(Database.BatchableContext BC) {   
        String query = 'SELECT Id, pedidoDigitado__c from pedidoDigitado__c where status__c != \'DESPACHADO\' AND status__c != \'ENTREGUE\' AND status__c != \'CANCELADO\' AND pedidoDigitado__c != \'\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<pedidoDigitado__c> scope){
        
        for(pedidoDigitado__c ped: scope)
        {
            String resp = buscaPedido(ped.pedidoDigitado__c);
            if(resp != null){
                Map<String,Object> mapPedido = (Map<String,Object>)JSON.deserializeUntyped(resp);
                Map<String,Object> mapStatus = (Map<String,Object>)mapPedido.get('Status');
                Map<String,Object> mapTransporte = (Map<String,Object>)mapPedido.get('Transportadora');
                Map<String,Object> mapServico = (Map<String,Object>)mapTransporte.get('ServicoEntrega');
                List<Object> listaRastreios = (List<Object>)mapServico.get('NumerosRastreio');

                ped.status__c = String.valueOf(mapStatus.get('Descricao'));
                ped.dataPedido__c = Helper.arrumaData(String.valueOf(mapPedido.get('DataRegistro')));
                ped.rastreio__c = String.valueOf(listaRastreios[0]);
            }
        }

        update scope;
    }
    global void finish(Database.BatchableContext BC){
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new MonitoraStatus(),10);
        System.abortJob(SC.getTriggerId());
    }

    public static String buscaPedido(String numeroPedido){
        String token = Helper.recuperaToken();

        HttpRequest req = new HttpRequest();
        String endURL = 'http://api.connectparts.com.br:8032/fenix/Pedido/Buscar?codigoExterno=' + numeroPedido + '&ignorarCancelados=false';
        req.setEndpoint(endURL); 
        req.setMethod('GET');
        req.setTimeout(20000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', '*/*');
        req.setHeader('Authorization', 'bearer ' + token);
        Http h = new Http();
        HttpResponse resp = h.send(req);

        if(resp.getStatusCode() == 200){
            return resp.getBody();
        }
        else{
            return null;
        }
    }

    
}

