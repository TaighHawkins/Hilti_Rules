%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT A&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_a_and_t_2, `04 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, due_date_year, `due date year storage` ).

i_rules_file( `d_hilti_it_postcode.pro` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_buyer_contact
	
	, get_buyer_ddi

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
	    , suppliers_code_for_buyer( `12999077` )                      %PROD
	]) ]  
	
	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `20673003` )                      %PROD
	]) ]    

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMAIL ADDRESSES + TWEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Addetto`, `acq`, `.`, `:` ], buyer_contact_x, s1 ] )
		
	, check( buyer_contact_x = Con_x )
	, check( sys_string_split( Con_x, ` `, Con_Split ) )
	, check( sys_reverse( Con_Split, Con_Rev ) )
	, check( wordcat( Con_Rev, Con ) )

	, delivery_contact( Con )
	, buyer_contact( Con )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Tel`, `.`, `:` ], 200, buyer_ddi, s1 ] )
	  
	, check( buyer_ddi = DDI )
	, delivery_ddi( DDI )
	
	, q(0,1,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( [ q0n(word), `@` ] ) ], buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line)
	  
	, generic_horizontal_details( [ [ `NUM`, `.`, `ORD`, `.` ], order_number, sf, [ `DEL`, generic_item( [ invoice_date, date ] ) ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `TOTALE`, `del`, dummy(s1) ], 300, total_net, d, newline ] )
	  
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
i_line_rule_cut( line_header_line, [ `Consegna`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ `Totale`, [ `Per`, `l`, `'` ] ] ) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [ 
%=======================================================================

	line_invoice_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( [ append( line_descr(s1), ` `, `` ), tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, or( [ generic_item( [ uom, d, [ `/`, other_uom_bit(s1), tab ] ] )
	
		, generic_item( [ ump, w, tab ] )
		
	] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).