%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CST 830
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( cst_830, `28 October 2013` ).

i_date_format( 'y-m-d' ).

i_format_postcode( X, X ).

i_user_field( line, potential_quantity, `possible quantity` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  fixed_variables

	, order_number_rule
	
	, order_date_rule

	, get_invoice_lines
	
	, get_totals_rule

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )
	
	, type_of_supply( `01` )
	
	, cost_centre( `Standard` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11238710` ) ]    %TEST
	    , suppliers_code_for_buyer( `17301108` )                      %PROD
	]) ]
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `11238710` ) ]    %TEST
	    , delivery_note_number( `19081406` )                      %PROD
	]) ]	
	
	, buyer_contact( `ERNST PETERS` )
	
	, buyer_ddi( `9055683899` )
	
	, buyer_email( `ernst_peters@commercialspring.com` )
	
	, delivery_contact( `ERNST PETERS` )
	
	, delivery_ddi( `9055683899` )
	
	, delivery_email( `ernst_peters@commercialspring.com` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( order_number_rule, [ 
%=======================================================================

	  q(0,10,line), order_number_line

] ).

%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	`LIN`, qn0(word)
	
	, `PO`, `~`
	
	, order_number(sf), q( 3, 3, `~` )
	
	, trace( [ `order number`, order_number ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( order_date_rule, [ 
%=======================================================================

	  q(0,10,line), order_date_line

] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	  `BFR`, qn0(word)
	
	, `~`
	
	, set( regexp_allow_partial_matching )

	, invoice_date(f([begin,q(dec,4,4),end]))

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, clear( regexp_allow_partial_matching )
	
	, q( 3, 3, `~` )
	
	, trace( [ `order date`, invoice_date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals_rule, [ 
%=======================================================================

	  q0n(line), get_totals_line

] ).

%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	`CTT`, `~`
	
	, read_ahead( [ total_net(d), `~` ] )
	
	, total_invoice(d), `~`
	
	, trace( [ `totals`, total_invoice ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_rule( get_invoice_lines, [
%=======================================================================

	  	
	  check( i_user_check( gen_cntr_set, 20, 0 ) )

	, qn0( line_invoice_rule )
	 
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [ 	
%=======================================================================

	  q0n(line), line_item_line
	  
	, q(0,10,line), line_quantity_line
	
	, or( [ quantity_calculation_rule, unknown_item_rule ] )
	
	, line_net_amount( `1` )
	
	, check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `LIN`, `~`, `~`, `BP`, `~`
	
	, line_item_for_buyer(w), `~`, `PO`
	
	, trace( [ `buyer item`, line_item_for_buyer ] )
	
	, qn0(word), `VP`, `~`
	
	, line_item(w), `*`
	
	, trace( [ `line_item`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( line_quantity_line, [
%=======================================================================

	  `FST`, `~`, potential_quantity(d), `~`
	
	, trace( [ `possible quantity`, potential_quantity ] )
	
] ).

%=======================================================================
i_rule_cut( quantity_calculation_rule, [ 	
%=======================================================================

	  trace( [ `inside calc rule` ] )
	
	, check( i_user_check( check_the_package_size, line_item, PACKAGE_SIZE, UOM ) )
	  
	, trace( [ `package size`, PACKAGE_SIZE, UOM ] )
	  
	, check( i_user_check( gen_same, potential_quantity,  POT_QTY ) )
	
	, trace( [ `made big`, POT_QTY ] )
	  
	, check( i_user_check( calculate_quantity, POT_QTY, PACKAGE_SIZE, UOM, QTY ) )
	
	, trace( [ `values`, POT_QTY, PACKAGE_SIZE, UOM, QTY ] )
	
	, line_quantity( QTY )
	
	, trace( [ `line qty`, line_quantity ] )

] ).

%=======================================================================
i_user_check( calculate_quantity, POT_QTY, PACKAGE_SIZE, UOM, QTY )
%-----------------------------------------------------------------------
:-
%=======================================================================

	  
	( sys_calculate_str_divide( POT_QTY, PACKAGE_SIZE, POT_PACK )
	
		, sys_calculate_str_add( POT_PACK, `0.49999`, POT_PACK_CHEAT )
	
		, sys_calculate_str_round_0( POT_PACK_CHEAT, POT_PACK_ROUND )
		
		, trace( analysis( POT_QTY, PACKAGE_SIZE, POT_PACK, POT_PACK_CHEAT, POT_PACK_ROUND ) )
		
		, ( q_sys_sub_string( UOM, _, _, `EA` )
		
			, sys_calculate_str_multiply( POT_PACK_ROUND, PACKAGE_SIZE, QTY )
		
			;
	
			q_sys_sub_string( UOM, _, _, `BOX` )
		
			, QTY = POT_PACK_ROUND 
	
		)
		
	)
		
	;
	
	QTY = POT_QTY
	
. %end%

%=======================================================================
i_rule_cut( unknown_item_rule, [ 	
%=======================================================================

	  trace( [ `unknown item code` ] )
	  
	, check( i_user_check( gen_same, potential_quantity, L_QTY ) )
	
	, line_quantity( L_QTY )
	
	, trace( [ `line quantity`, line_quantity ] )

] ).

%=======================================================================
%  lookup
%-----------------------------------------------------------------------

i_user_check( check_the_package_size, ITEM_NUMBER, PACKAGE_SIZE, UOM )
:-
	item_package_size( ITEM_NUMBER, PACKAGE_SIZE, UOM )
.


item_package_size( `50353`, `100`, `BOX`).
item_package_size( `237332`, `100`, `BOX`).
item_package_size( `237333`, `100`, `BOX`).
item_package_size( `277271`, `120000`, `EA`).
item_package_size( `277272`, `120000`, `EA`).
item_package_size( `288581`, `110000`, `EA`).
item_package_size( `288582`, `100000`, `EA`).
item_package_size( `388532`, `1000`, `BOX`).
item_package_size( `408364`, `45000`, `EA`).




i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, `COMMERCIAL SPRING & TOOL COMPANY` ), _, _, _, _) :- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME2, `COMMERCIAL SPRING & TOOL COMPANY` ), _, _, _, _) :- result( _, invoice, delivery_contact, NU2 ), string_to_upper(NU2, NAME2).