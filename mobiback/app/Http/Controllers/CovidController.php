<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Throwable;


// André Luiz
// Controlador responsável pelos dados oriundos dos serviços 

class CovidController extends Controller
{

    // obter os dados 
    public function getCases($status, $nmonths = 6)
    {
        // validar status
        if (!str_contains("confirmed|recovered|deaths", $status)) {
            return $this->responseMsg("Os status permitidos são 'confirmed', 'recovered', 'deaths'.");
        }

        // calculando a data inicial e final, conforme o número de meses passados
        $startDate = Carbon::now()->subMonths(intval($nmonths))->startOfMonth()->subDay()->toISOString();
        $endDate = Carbon::now()->startOfDay()->toISOString();

        // tentar obter resposta
        try {
            $resp = Http::retry(3, 100)->get("https://api.covid19api.com/total/country/brazil/status/$status?from=$startDate&to=$endDate");

            // conseguiu? obtenha somente os dados necessários e retorne a array
            if ($resp->successful()) {
                $data = json_decode($resp->getBody()->getContents(), true);
                $retData = [];
                $first = true;
                $ltotal = 0;
                foreach ($data as $r) {
                    if (!$first) {
                        $daily = $r["Cases"] - $ltotal;
                        $retData[] = [
                            "date" => $r["Date"],
                            "cases" => $daily,
                            "total" => $r["Cases"]
                        ];
                    }
                    $ltotal = $r["Cases"];
                    $first = false;
                }
                return $this->responseData($retData);
            }
            // senão, retorna o status e conteúdo como texto
            return $this->responseMsg("ERROR {$resp['statusCode']}: " . $resp->getBody()->getContents());
        } catch (Throwable $e) {
            // se houve erro, cria um log e retorna mensagem de erro.
            Log::error('Falha ao acessar o servido de Covid 19: ' . $e->getMessage());
            return $this->responseMsg("ERROR: " . $e->getMessage());
        }
    }
}
