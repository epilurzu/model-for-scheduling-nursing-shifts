/*********************************************
 * OPL 20.1.0.0 Model
 * Author: epilurzu
 * Creation Date: Mar 1, 2021 at 3:50:15 PM
 *********************************************/
int n_combinazioni = ...;

range r_combinazioni = 0..n_combinazioni-1;
{string} giorni = ...;
{string} turni = ...;

int n_infermieri_giovedi_r = ...;
int n_infermieri_senza_notti = ...;
int n_infermieri_combinazione_speciale = ...;
 
int n_infermieri_minimi[giorni][turni] = ...;
int combinazioni[r_combinazioni][giorni][turni] = ...;

dvar int combinazione[r_combinazioni];

	minimize
		sum (c in r_combinazioni)
			combinazione[c];
	subject to
	{		 
		// Vincolo infermieri minimi
		forall(g in giorni, t in turni)
			sum(c in r_combinazioni)
				combinazioni[c][g][t] * combinazione[c] >= n_infermieri_minimi[g][t];

		// Vincolo Giovedi giorno di riposo
		sum(c in r_combinazioni: combinazioni[c]["Mercoledi"]["Notte"] == 0
							  && combinazioni[c]["Giovedi"]["Mattina"] == 0
							  && combinazioni[c]["Giovedi"]["Sera"] == 0
							  && combinazioni[c]["Giovedi"]["Notte"] == 0)
				 combinazione[c] >= n_infermieri_giovedi_r;
		            
		// Vincolo turni senza notti
		sum(c in r_combinazioni: combinazioni[c]["Lunedi"]["Notte"] == 0
							  	 && combinazioni[c]["Martedi"]["Notte"] == 0
							  	 && combinazioni[c]["Mercoledi"]["Notte"] == 0
								 && combinazioni[c]["Giovedi"]["Notte"] == 0
							  	 && combinazioni[c]["Venerdi"]["Notte"] == 0
							  	 && combinazioni[c]["Sabato"]["Notte"] == 0
								 && combinazioni[c]["Domenica"]["Notte"] == 0)
	  			combinazione[c] >= n_infermieri_senza_notti;

		// Vincolo combinazioni positive o nulle
		forall(c in r_combinazioni)
	    	if(c == 216)
	  			combinazione[c] == n_infermieri_combinazione_speciale;	//La combinazione speciale deve essere unica
	  		else
	  			combinazione[c] >= 0;
	}

execute DISPLAY
{
  	writeln ("\n Infermieri necessari: ", cplex.getObjValue());
	var c, g, t;
	
	var n_infermieri_di_turno = new Array();
	for(g in giorni){
		n_infermieri_di_turno[g] = new Array();
 		for(t in turni){
 			n_infermieri_di_turno[g][t] = 0;	  
 		}
 	}
	
	writeln("\n Combinazioni necessarie per minimizzare la funzione obiettivo: \n");
	for(c in r_combinazioni){
		if(combinazione[c] != 0){
			var s = "";
			for(g in giorni){
				if (combinazioni[c][g]["Mattina"] == 1){
					s = s + "1";
					n_infermieri_di_turno[g]["Mattina"] += 1*combinazione[c];
				}
				else if (combinazioni[c][g]["Sera"] == 1){
					s = s + "2";
					n_infermieri_di_turno[g]["Sera"] += 1*combinazione[c];
				}
				else if (combinazioni[c][g]["Notte"] == 1){
					s = s + "3";
					n_infermieri_di_turno[g]["Notte"] += 1*combinazione[c];
				}
				else{
				 	var ultimo_carattere = s.charAt(s.length - 1);
				  	if(ultimo_carattere == "3"){
						s = s + "s";
   					}					
					else{
						s = s + "r";
   					}					  
				}	
 			}
 			writeln("\tCombinazione n ",c,"\t(",s,"): ", combinazione[c]);
 		}			
 	}
 	
 	writeln("\n Infermieri in servizio a confronto con il numero minimo richiesto: \n");
 	
 	writeln("\t Giorno \t| Turno\t\t\t| Minimi \t\t| In servizio");
 	writeln("-------------------------------------------------------------------");
 	for(g in giorni){
 		for(t in turni){ 		
 			writeln("\t ",g," \t| ",t,"  \t\t| ",n_infermieri_minimi[g][t]," \t\t\t| ",n_infermieri_di_turno[g][t]);
 			writeln("-------------------------------------------------------------------");  
 		}
 	}
 }