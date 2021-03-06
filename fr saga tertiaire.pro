%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SAGA TERTIAIRE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( saga_tertiaire, `20 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( x_tolerance_100, 100 ).

i_rules_file( `hilti french order format 1.pro` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]	
				, suppliers_code_for_buyer( `17498136` )		
	] )

	, sender_name( `Saga Tertiaire` )
	
	, type_of_supply(`01`)
	, set( reverse_punctuation_in_numbers )
	, set( leave_spaces_in_order_number )

] ).

address_lookup( `AVENUE MATIGNON`, `75008`, `21518145` ).
address_lookup( `RUE DE BASSANO`, `75008`, `21195437` ).
address_lookup( `AVENUE DE FRIEDLAND`, `75008`, `21292227` ).
address_lookup( `AVENUE DE SUFFREN`, `75015`, `20327859` ).
address_lookup( `RUE DES MARCHAIS`, `75019`, `21859681` ).
address_lookup( `19 AVENUE KLEBER`, `75116`, `19298621` ).
address_lookup( `6 AVENUE KLEBER`, `75116`, `21673773` ).
address_lookup( `AVENUE MORANE SAULNIER`, `78140`, `20804231` ).
address_lookup( `PLACE DE LA PAIX CELESTE`, `78180`, `21403537` ).
address_lookup( `RUE DE L'ESPAGNE`, `91550`, `21754691` ).
address_lookup( `RUE DES SORINS`, `92000`, `21965868` ).
address_lookup( `1198 RUE DU VIEUX PONT DE SEVRES`, `92100`, `20882815` ).
address_lookup( `1798 RUE DU VIEUX PONT DE SEVRES`, `92100`, `20882815` ).
address_lookup( `COURS DE L'ILE SEGUIN`, `92100`, `22002725` ).
address_lookup( `RUE GABRIEL PERI`, `92120`, `21062565` ).
address_lookup( `AVENUE GABRIEL PERI`, `92120`, `21062565` ).
address_lookup( `RUE ANCELLE`, `92200`, `20820128` ).
address_lookup( `RUE VICTOR HUGO`, `92270`, `17498136` ).
address_lookup( `BOULEVARD DE NEUILLY`, `92400`, `20691301` ).
address_lookup( `RUE DE BEZONS`, `92400`, `21019786` ).
address_lookup( `AVENUE GAMBETTA`, `92400`, `18633930` ).
address_lookup( `RUE OLYMPE DE GOUGES`, `92600`, `21869529` ).
address_lookup( `AVENUE DES FRUITIERS`, `93210`, `19857999` ).
address_lookup( `RUE D'ARCUEIL`, `94150`, `21346400` ).
address_lookup( `AVENUE GUY MOQUET`, `94460`, `19940230` ).