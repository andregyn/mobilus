<?php

namespace App\Http\Controllers;

use App\Models\ServiceResponse;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    public const NOT_FOUND = "ERRO: Registro não encontrado.";
    function responseError()
    {
        $resp = new ServiceResponse();
        $resp->message = "ERRO";
        $resp->data = [];
        $resp->recordsTotal = 0;
        return response()->json($resp);
    }

    // André Luiz
    // Retorna resposta OK, sem dados
    function responseOk()
    {
        $resp = new ServiceResponse();
        $resp->message = "OK";
        $resp->data = [];
        $resp->recordsTotal = 0;
        return response()->json($resp);
    }

    // André Luiz
    // Retorna resposta OK, COM dados
    function responseData($l)
    {
        $resp = new ServiceResponse();
        $resp->message = "OK";
        $resp->data = $l;
        $resp->recordsTotal = sizeof($l);
        return response()->json($resp);
    }


    // André Luiz
    // Retorna resposta com mensagem personalizada
    function responseMsg($msg = self::NOT_FOUND)
    {
        $resp = new ServiceResponse();
        $resp->message = $msg;
        $resp->data = null;
        $resp->recordsTotal = 0;
        return response()->json($resp);
    }
}
