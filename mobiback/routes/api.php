<?php

use App\Http\Controllers\CovidController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// André Luiz
// Vamos deixar quieto isso por enquanto, pois não será necessário autenticação, conforme escopo proposto no projeto.
// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });

// André Luiz
// Requisito 1 do projeto de avaliação: Buscar (GET) todos os casos de covid 19 no brasil nos ultimos 6 memes
Route::get('cases/{status}/{nmonths}', [CovidController::class, 'getCases']);
