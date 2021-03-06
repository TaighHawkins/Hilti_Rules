%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE KONE INDUSTRIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_kone_industrial, `03 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_vert_capture( [ [ `Buyer`, `'`, `s`, `order`, `number` ], order_number, s1 ] )
	, gen_vert_capture( [ [ `Date`, tab, `Date`, `Modif` ], invoice_date, date ] )
	
	, get_delivery_address
	
	, get_contact_details
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, gen_vert_capture( [ [ `Total`, `price`, tab, `Total` ], `price`, end, total_net, d ] )
	, gen_vert_capture( [ [ `Total`, `price`, tab, `Total` ], `price`, end, total_invoice, d ] )

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([
	  [ test(test_flag), suppliers_code_for_buyer( `11264432` ) ]    %TEST
	    , suppliers_code_for_buyer( `14132519` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `KONE Industrial Oy` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================	  

	  q0n(line), generic_horizontal_details( [ [ at_start, `Delivery`, `address` ] ] )
	
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
	, q01( delivery_thing( [ delivery_address_line ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_city_postcode_line
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [
%=======================================================================	  

	  nearest( generic_hook(start), 10, 10 )

	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_postcode_line, [
%=======================================================================	  

	  nearest( generic_hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_details, [
%=======================================================================

	  q0n(line), generic_line( [ [ `For`, `further`, `information`, `,`, `please`, `contact` ] ] )
	
	, generic_horizontal_details( [ or( [ [ `Ms`, `.` ], `Mr` ] ), buyer_contact, s1, newline ] )
	, check( buyer_contact = Contact )
	, delivery_contact( Contact )
	
	, generic_horizontal_details( [ [ `Email`, `:` ], buyer_email, s1, newline ] )
	, check( buyer_email = Email )
	, delivery_email( Email )
	
	, generic_horizontal_details( [ [ `Tel`, `:` ], ddi, s1, newline ] )
	, check( i_user_check( clean_up_number, ddi, DDI ) )
	, buyer_ddi( DDI )
	, delivery_ddi( DDI )
	
	, generic_horizontal_details( [ `Fax`, fax, s1, newline ] )
	, check( i_user_check( clean_up_number, fax, Fax ) )
	, buyer_fax( Fax )
	, delivery_fax( Fax )
	
] ).

%-----------------------------------------------------------------------
i_user_check( clean_up_number, Num_in, Num_out )
%=======================================================================
:-
	strip_string2_from_string1( Num_in, ` `, Num ),
	string_string_replace( Num, `+`, `00`, Num_out ),
	trace( number_out( Num_out ) )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, qn0( [ peek_fails( line_end_line )

		, or( [
		
			line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Item`, `Material`, `N`, `°`, `/`, `Description`, tab
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `Currency`, tab, `Total`, `price`
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_horizontal_details( [ at_start, line_descr, s1 ] )
	
	, q10( [ q10( [ q(0,3,line), generic_line( [ `Discount` ] ) ] ), q01(line)
	
		, q10( generic_horizontal_details( [ [ `SO`, `Nr`, `:` ], line_item_for_buyer, s1, newline ] ) )
	
		, generic_horizontal_details( [ [ `Mfr`, `.`, `Part`, `Nr`, `:` ], line_item, [ begin, q(dec,4,10), end ] ] )
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_order_line_number, d ] )
	
	, generic_item( [ material_no_, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, q01( generic_item( [ req_date_time_, s1, tab ] ) )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_no( [ line_unit_amount, d, [ `/`, tab ] ] )
	
	, generic_no( [ line_net_amount, d, newline ] )

] ).