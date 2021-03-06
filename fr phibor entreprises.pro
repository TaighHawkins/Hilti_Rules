%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PHIBOR ENTREPRISES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( phibor_entreprises, `03 July 2015` ).

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
				, suppliers_code_for_buyer( `11716668` )		
	] )
	
	, or( [ [ test( test_flag ), delivery_note_number( `` ) ]	
				, delivery_note_number( `21329185` )		
	] )

	, sender_name( `Phibor Entreprises` )
	
	, type_of_supply(`01`)
	, set( reverse_punctuation_in_numbers )
	, set( leave_spaces_in_order_number )

] ).

%=======================================================================
i_analyse_line_fields_first( LID )
%-----------------------------------------------------------------------
:- i_alter_quantities( LID ).
%=======================================================================
i_alter_quantities( LID )
%-----------------------------------------------------------------------
:-
	result( _, LID, line_quantity, Qty ),
	result( _, LID, line_quantity_uom_code, UoM ),
	string_to_lower( UoM, UoML ),
	UoML = `cent`,
	
	sys_calculate_str_multiply( Qty, `100`, NewQty ),
	sys_retract( result( _, LID, line_quantity, _ ) ),
	sys_retract( result( _, LID, line_quantity_uom_code, _ ) ),
	assertz_derived_data( LID, line_quantity, NewQty, i_alter_quantities ),
	!
.
%=======================================================================
	
address_lookup( `FOSSES SAINT-BERNARD`, `75005`, `20469969` ).
address_lookup( `QUAI SAINT-BERNARD`, `75005`, `20492250` ).
address_lookup( `IMPASSE D'AMSTERDAM`, `75008`, `21474678` ).
address_lookup( `TRONSON DU COUDRAY`, `75008`, `22032454` ).
address_lookup( `COLONEL FABIEN`, `75010`, `21300583` ).
address_lookup( `RAYMOND LOSSERAND`, `75014`, `21279993` ).
address_lookup( `FIRMIN GILLOT`, `75015`, `21903927` ).
address_lookup( `JEAN REY`, `75015`, `20503739` ).
address_lookup( `LUCIEN BOSSOUTROT`, `75015`, `21567536` ).
address_lookup( `PIERRE AVIA`, `75015`, `21568233` ).
address_lookup( `GUSTAVE CHARPENTIER`, `75017`, `20389895` ).
address_lookup( `KLEBER`, `75116`, `20081702` ).
address_lookup( `JOHANNES GUTENBERG`, `77700`, `21810876` ).
address_lookup( `MORANE SAULNIER`, `78140`, `20970654` ).
address_lookup( `SAINT ANTOINE`, `78150`, `21719781` ).
address_lookup( `AVENUE DU CENTRE`, `78280`, `19686520` ).
address_lookup( `NATIONALE`, `92100`, `22015718` ).
address_lookup( `VIEUX PONT DE SEVRES`, `92100`, `21573136` ).
address_lookup( `JEAN JAURES`, `92110`, `19422188` ).
address_lookup( `GABRIEL PERI`, `92120`, `21040009` ).
address_lookup( `CAMILLE DESMOULINS`, `92130`, `21214478` ).
address_lookup( `ACHILLE PERETTI`, `92200`, `20909692` ).
address_lookup( `BATISSEURS`, `92400`, `20898690` ).
address_lookup( `DE STRASBOURG`, `92400`, `21924350` ).
address_lookup( `MONTAIGNE`, `93160`, `21334911` ).
address_lookup( `CRISTINO GARCIA`, `93210`, `21807052` ).
address_lookup( `FRUITIERS`, `93210`, `21384154` ).
address_lookup( `PRESIDENT WILSON`, `93210`, `19869315` ).
address_lookup( `STADE DE FRANCE`, `93210`, `21735197` ).
address_lookup( `DOCTEUR TRONCIN`, `93300`, `21917340` ).
address_lookup( `GALIEN`, `93400`, `21537712` ).
address_lookup( `ROBERT BALLANGER`, `93600`, `20600146` ).
address_lookup( `GENERAL DE GAULLE`, `94000`, `21364892` ).
address_lookup( `D'ARCUEIL`, `94150`, `21156919` ).
address_lookup( `MONTLHERY`, `94150`, `11716668` ).
address_lookup( `PASTEUR`, `94160`, `20024134` ).
address_lookup( `L'UNION`, `94310`, `21561997` ).
address_lookup( `L'OISE`, `95800`, `21667654` ).
address_lookup( `MONTLHERY`, `94150`, `11716668` ).
address_lookup( `DOCTEUR ROUX`, `75015`, `22255188` ).
address_lookup( `CAMBRAI`, `75019`, `22259121` ).
address_lookup( `AVENUE DE SAXE`, `75007`, `22390977` ).