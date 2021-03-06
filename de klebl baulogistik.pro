%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE KLEBL BAULOGISTIK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_klebl_baulogistik, `22 April 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date
	
	, get_due_date

	, get_delivery_details

	, get_contacts
	
	, get_emails
	
	, get_faxes
	
	, get_ddis
	
	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

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

	, suppliers_code_for_buyer( `10281664` )
	
	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, sender_name( `Klebl Baulogistik GmbH` )
	
	, set( reverse_punctuation_in_numbers )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Bestellung`, `Nr`, `.`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Datum` ], 200, invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Lieferdatum` ], due_date, date ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ `Bearbeiter`, buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Telefon`, `(`, `Anschl`, `.`, q10( `)` ) ], buyer_ddi_x, s1 ] )
		  
	, check( buyer_ddi_x = DDI )
	
	, check( strip_string2_from_string1( DDI, `-`, DDI_2 ) )

	, buyer_ddi( DDI_2 )
	, delivery_ddi( DDI_2 )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Fax`, `(`, `Anschl`, `.`, q10( `)` ) ], buyer_fax_x, s1 ] )
		  
	, check( buyer_fax_x = Fax )
	
	, check( strip_string2_from_string1( Fax, `-`, Fax_2 ) )
	
	, buyer_fax( Fax_2 )
	, delivery_fax( Fax_2 )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), `E`, `-`, `Mail` ], buyer_email, s1 ] )
	  
	, check( buyer_email = Email )	
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ `Lieferadresse`, `:`, q10( tab ), generic_item( [ delivery_party, s1 ] ) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), delivery_header_line

	, q10( delivery_thing( [ delivery_dept ] ) )
	
	, q(0,2, delivery_thing( [ delivery_address_line ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [ nearest( delivery_party(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  nearest( delivery_party(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ q(0,40,line), customer_comments_line( 1, -500, 0 ) ] ).
%=======================================================================
i_line_rule( customer_comments_line, [
%=======================================================================

	  retab( [ 9000 ] )
	
	, read_ahead( `Kostenstelle` )
 
	, generic_item( [ customer_comments, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line), read_ahead( generic_horizontal_details( [ [ `Total`, `(`, `EUR`, `)` ], 500, total_net, d, newline ] ) )

	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, qn0( [ peek_fails( line_end_line )

		  , or( [ 
		
			  line_invoice_rule
			  
			, line_continuation_line

			, line

		] )

	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Nr`, `.`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Total`, `(`, `EUR`, `)` ], [ `Übe`, `.`, `rt`, `.`, `ra`, `.`, `g` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, generic_line( [ generic_item( [ line_descr, s1, newline ] ) ] )
	
	, q(2,0, or( [ line_item_line, line_continuation_line ] ) )
	
	, or( [ peek_fails( test( discounted_line ) )
	
		, [ test( discounted_line )
			, line_discount_line
			, generic_line( [ generic_item( [ line_net_amount, d, newline ] ) ] )
		]
	] )

	, q10( [ with( invoice, due_date, Due )	
		, line_original_order_date( Due )
	] )
	
	, q10( [ test( need_item ), line_item( `Missing` ), clear( need_item ) ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, [ begin, q(dec,2,2), end, q(dec,3,4) ], tab ] )

	, or( [ [ peek_fails( `999999` ), generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] ) ]
	
		, set( need_item )
	] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, or( [ [ generic_item_cut( [ line_price_uom_code, d, tab ] )

			, generic_item_cut( [ line_unit_amount, d, tab ] )
			
			, generic_item_cut( [ non_discounted_net, d ] )
			
			, or( [ [ tab, generic_item( [ line_net_amount, d, newline ] ) ]
			
				, [ newline, set( discounted_line ) ]
				
			] )
			
		]
		
		, generic_item_cut( [ line_price_uom_code, d, newline ] )
	
	] )

] ).

%=======================================================================
i_line_rule_cut( line_discount_line, [
%=======================================================================

	  `Rabatt`, tab, `-`, generic_item( [ line_percent_discount, d, tab ] )
	  
	, `-`, generic_item( [ line_amount_discount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [ test( need_item ),
%=======================================================================

	qn0( 
		or( [ `Best`
			, `Nr`
			, `.`
		] )
	)
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], newline ] )
	, clear( need_item )

] ).