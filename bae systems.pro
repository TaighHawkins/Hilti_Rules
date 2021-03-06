%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BAE SYSTEMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( bae_systems, `17 June 2014` ).

i_pdf_parameter( no_scaling, 1 ).

%=======================================================================
% IDOC ALTERATION
%=======================================================================
i_user_field(invoice, picking, `Picking` ).
i_orders05_idocs_e1edkt1( `Z011`, picking ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_order_lines

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

%%% Agent Codes

	  agent_code_3( `4400` )
	, agent_code_2( `01` )
	, agent_code_1( `00` )
	, agent_name( `GBADAPTRIS` )
	
%%% Contact Info

	, buyer_contact( `RYAN O'NEILL` )
	
	, buyer_ddi( `01419574956` )
	
	, buyer_email( `ryan.oneill@baesystems.com` )
	
%%% Routing Information

	, suppliers_code_for_buyer( `16750970` )
		
	, buyer_registration_number( `GB-ADAPTRI` ) %%% ---- Will be changing to `GB-BAESYS` at some point
		
	, buyer_party( `LS` )

	, delivery_note_number( `21286166` )
		  
	, supplier_party( `LS` )

	, [ or([ 
			[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
			, supplier_registration_number( `P11_100` )                      %PROD
		]) 
	]

%%% Invoice Type and Shipping

	, invoice_type( `02` )

	, type_of_supply( `G2` )
	
%%% Picking information

	, picking( `****PLEASE PICK BUT DO NOT SHIP****

	****PUT IN BAE HOLD AREA****
	
	*** PLEASE INFORM GARY PARKER****` )
	
	, total_net( `0` )
	
	, total_invoice( `0` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [  order_number( `CVF16000300` ), invoice_date( Today_string ), trace( [ order_number, invoice_date, `order number and date` ] ) ] ):-
%=======================================================================

	date_get( today, Date ),
	
	trace( [ Date ] ), 
	
	sys_date_1900_days( Date, Date_count ),
	
	trace( [ `Date Count`, Date_count ] ),

	sys_calculate( Today_30, Date_count + 30 ),
	
	trace( [ `Today 30`, Today_30 ] ),

	sys_date_1900_days( Today_new, Today_30 ),
	
	trace( [ `here`] ),
	
	date_string( Today_new, 'd/m/y', Today_string )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( line_header_line, [ `PART`, `CLASSIFICATION`, q10( tab ), `ACA`, `Part`, `Number` ] ).
%=======================================================================
i_section( get_order_lines, [ 
%=======================================================================

	  line_header_line
	
	, qn0( 
		or( [ 
			  line_order_line
			  
			, line_sanity_check_line
			
			, line			
		] )
		
	)
	
] ).

%=======================================================================
i_line_rule_cut( line_order_line, [ 
%=======================================================================

	  generic_item( [ trash, s, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, w, tab ] )
	
	, generic_item( [ line_item, w, q10( tab ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_order_line_number, d, newline ] )
	
	, line_net_amount( `0` )
	
	, line_quantity_uom_code( `PC` )
	
] ).

%=======================================================================
i_line_rule_cut( line_sanity_check_line, [ 
%=======================================================================

	  q0n(anything)
	  
	, tab, dummy(d)
	
	, check( dummy(start) > 200 )
	
	, force_result( `defect` )
	
] ).

check_month( `1`, `01` ).
check_month( `2`, `02` ).
check_month( `3`, `03` ).
check_month( `4`, `04` ).
check_month( `5`, `05` ).
check_month( `6`, `06` ).
check_month( `7`, `07` ).
check_month( `8`, `08` ).
check_month( `9`, `09` ).
check_month( `10`, `10` ).
check_month( `11`, `11` ).
check_month( `12`, `12` ).