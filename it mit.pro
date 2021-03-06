%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT MIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_mit, `09 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_rules_file( `d_hilti_it_postcode.pro` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, get_delivery_details

	, get_buyer_contact
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals
	

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `13147441` )                      %PROD
	]) ]    

	, set( reverse_punctuation_in_numbers )
	
	, delivery_party( `M.I.T. s.r.l` )
	, sender_name( `M.I.T. s.r.l` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `Compilato`, `da`, `:` ], buyer_contact_x, s1 ] )
		
	, check( buyer_contact_x = Con_x )
	, check( sys_string_split( Con_x, ` `, Con_Split ) )
	, check( sys_reverse( Con_Split, Con_Rev ) )
	, check( wordcat( Con_Rev, Con ) )

	, delivery_contact( Con )
	, buyer_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_vertical_details( [ [ `Numero`, tab, `Data` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_vertical_details( [ [ `Data`, tab, `Pagina` ], invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line)
	  
	, generic_horizontal_details( [ [ at_start, `Consegna`, q0n(word) ], due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ at_start, `Luogo`, `di`, `consegna` ] ] )
	
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 30 ), delivery_dept, s1 ] )
	, q01( generic_line( [ [ nearest( generic_hook(end), 10, 30 ), append( delivery_dept(s1), ` `, `` ) ] ] ) )
	, generic_horizontal_details( [ nearest( generic_hook(end), 10, 30 ), delivery_street, s1 ] )

	, delivery_postcode_city_line
	
	, q10( [ check( delivery_dept = Dept )
		, check( string_to_lower( Dept, DeptL ) )
		, check( q_sys_sub_string( DeptL, _, _, `questura di monza` ) )
		, delivery_location( `QUESTURA DI MONZA` )
		
		, remove( delivery_dept )
		, remove( delivery_state )
		, remove( delivery_street )
		, remove( delivery_city )
		, remove( delivery_postcode )
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  nearest( generic_hook(end), 10, 30 )
	  
	, or( [ generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ], `-` ] ), [ `-`, set( no_postcode ) ] ] )
	, generic_item( [ delivery_city, sf, or( [ [ `(`, generic_item( [ delivery_state, wf, `)` ] ) ], [ gen_eof, set( no_region ) ] ] ) ] )
	
	, q10( [ test( no_postcode )
		, check( i_user_check( check_for_region, PC, delivery_state ) )
		, delivery_postcode( PC )
		, trace( [ `Looked up PC`, PC ] )
	] )
	
	, q10( [ test( no_region )
		, check( i_user_check( check_for_region, delivery_postcode, State ) )
		, delivery_state( State )
		, trace( [ `Looked up state`, State ] )
	] )
	
] ).

%=======================================================================
i_user_check( check_for_region, PC, State ):- postcode_lookup( PC, _, State, _ ).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	  q(0,40,line), peek_ahead( generic_horizontal_details( [ [ at_start, `Altre`, `Note` ] ] ) )
	
	, peek_ahead( gen_count_lines( [ generic_line( [ [ `Il`, `presente`, `ordine` ] ] ), Count ] ) )
	
	, generic_line( Count, -500, 500, [ [ `Altre`, `Note`, `:`, tab, generic_item( [ customer_comments, s1 ] ) ] ] )
	
	, check( customer_comments = Customer )
	, shipping_instructions( Customer )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( [ `TOTALE`, `ORDINE` ] ) ], dummy, w ] )
	  
	, q(0,5,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `€` ], total_net, d, newline ] )
	
	, check( total_net = Net )
	, total_invoice( Net )

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

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `ATT`, tab, `CODICE` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `COPIA`, `DEL`, `PRESENTE` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
	, with( invoice, due_date, Due )
	, line_original_order_date( Due )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_x, s1, tab ] )
	, check( line_item_x = ItemX )
	, check( strip_string2_from_string1( ItemX, `HIL`, Item ) )
	, line_item( Item )
	, trace( [ `Line Item`, Item ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ iva, d, q10( tab ) ] )
	
	, q10( generic_item( [ line_quantity_uom_code, s1, tab ] ) )

	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )

	, generic_item( [ line_percent_discount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).