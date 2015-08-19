%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH DEBRUNNER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


i_version( ch_debrunner, `06 July 2015` ).
i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address
	
	, get_scfb

	, get_buyer_contact
	
	, get_order_number
	
	, get_order_date
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, total_net( `0` )
	, total_invoice( `0` )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_scfb, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Kunden`, `-`, `Nr`, `.`, `:` ], suppliers_code_for_buyer, s1 ] )
	  
	, q10( [ without( delivery_party )
		, check( i_user_check( get_party_from_scfb, suppliers_code_for_buyer, Party ) )
		, delivery_party( Party )
		, trace( [ `Delivery Party`, Part ] )
		
		, check( suppliers_code_for_buyer = SCFB )
		, delivery_note_number( SCFB )		
	] )
	
] ).

%=======================================================================
i_user_check( get_party_from_scfb, SCFB, Party ):- customer_lookup( SCFB, Party ). 
%=======================================================================

customer_lookup( `10480493`, `Aerni AG` ).
customer_lookup( `10503148`, `casa-technica.ch` ).
customer_lookup( `10535055`, `Hälg + Co. AG` ).
customer_lookup( `10535672`, `Kreis Wasser AG` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q(0,15,line), delivery_header_line
	  
	, delivery_thing_line( [ delivery_party ] )
	
	, q10( [ check( q_sys_sub_string( delivery_party, _, _, `Hälg` ) ), set( halg ) ] )
	
	, delivery_thing_line( [ delivery_dept ] )
	
	, q10( delivery_thing_line( [ delivery_address_line ] ) )

	, delivery_thing_line( [ delivery_street ] )
	
	, delivery_city_postcode_line  
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ q0n( [ dummy(s1), tab ] ), read_ahead( [ `Lieferung`, `an` ] ), delivery_hook(s1) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [ 
%=======================================================================

	  nearest( delivery_hook(start), 15, 15 )
	  
	, generic_item( [ Variable, s1 ] )
	
] ).


%=======================================================================
i_line_rule( delivery_city_postcode_line, [ 
%=======================================================================
	
	  nearest( delivery_hook(start), 15, 15 )
	  
	, delivery_postcode(f( [ begin, q(dec,4,5), end ] ) )
	
	, delivery_city(s1)
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Bestell`, `-`, `Nr`, `.`, `:` ], order_number, s1 ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Datum`, `:` ], 200, invoice_date, date ] )
	  
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ Search, `:` ], 250, buyer_contact, s1 ] )
	 
] ):- grammar_set( halg ) -> Search = `Kommission` ; Search = `Besteller`.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q(0,20,line), generic_vertical_details( [ [ `Objekt`, `:` ], customer_comments, s1 ] )
	 
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
 
	, trace( [ `found header` ] )

	, qn0(

		or( [  line_invoice_line
			
				, line

		] )

	)

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Artikel`, `-`, `Nr` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_item, w, tab ] )
	  
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, fd( [ begin, q([dec,other_skip("'")],1,10), q(other("."),1,1), q(dec,2,2), end ] ), q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, newline ] )
	
] ).