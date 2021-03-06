%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE TBS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_tbs, `23 February 2015` ).

i_pdf_parameter( same_line, 6 ).

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

	, get_faxes
	
	, get_ddis
	
	, get_emails
	
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

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `11261632` ) ]    %TEST
	    , suppliers_code_for_buyer( `10124611` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
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
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Bestell`, `-`, `Nr` ], order_number, sf, or( [ tab, `Datum` ] ) ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Datum`, `:` ], invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], due_date, date ] )
	
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
	  
	, generic_horizontal_details( [ [ `Kontakt`, `:` ], buyer_contact, s1 ] )
	
	, check( buyer_contact = Con )
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Tel`, `:`, `-` ], buyer_ddi_x, s1 ] )

	, check( buyer_ddi_x = DDIEnd )

	, wrap( buyer_ddi( DDIEnd ), `082549976`, `` )
	, wrap( delivery_ddi( DDIEnd ), `082549976`, `` )

] ).

%=======================================================================
i_rule( get_faxes, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Fax`, `:`, `-` ], buyer_fax_x, s1 ] )

	, check( buyer_fax_x = FaxEnd )

	, wrap( buyer_fax( FaxEnd ), `082549976`, `` )
	, wrap( delivery_fax( FaxEnd ), `082549976`, `` )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `eMail`, `:` ], buyer_email, s1 ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q0n(line)
	, generic_horizontal_details( [ read_ahead( [ `KST`, `/` ] ), ccx, s1
		, [ check( ccx = CC )
			, or( [ [ with( customer_comments ), append( customer_comments( CC ), `~`, `` ) ]
				, customer_comments( CC )
			] )
			, tab, append( customer_comments(s1), `~` , `` ) 
			, q10( [ tab, append( customer_comments(s1), ` `, `` ) ] )
		] 
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ at_start, `Firma`, `:` ], delivery_party_x, s1 ] )
	  
	, check( delivery_party_x = PartyX ) 
	, delivery_party( `TBS Brandschutzanlagen GmbH` )
	, xor( [ check( PartyX = `TBS Brandschutzanlagen GmbH` )
		
		, [ delivery_dept( PartyX )
			, trace( [ `Delivery Dept`, delivery_dept ] )
		]
	] )

	, q(0,3,line), generic_horizontal_details( [ [ `Strasse`, `:` ], delivery_street, s1 ] )
	
	, q(0,3,line), generic_horizontal_details( [ [ `Ort`, `:` ], delivery_postcode, s1, [ tab, generic_item( [ delivery_city, s1 ] ) ] ] )
	
	, q10( [ q(0,7,line)
		, generic_horizontal_details( [ [ `z`, `.`, `Hd`, `.`, tab ], shipping_instructions, s1 ] )
		, q(0,2,line)
		, generic_line( [ [ `Telefon`, `:`, q10( tab ), append( shipping_instructions(s1), `~`, `` ) ] ] )
	] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	  
	, generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), read_ahead( generic_horizontal_details( [ [ `Gesamtbetrag`, `netto`, `:` ], 300, total_net, d ] ) )
	  
	, check( total_net = Net )
	, total_invoice( Net )
	
	, q10( [ check( q_sys_comp_str_eq( Net, `0` ) )
		, set( no_total_validation )
	] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  peek_ahead( line_header_line )
	 
	, trace( [ `found header` ] )

	, or( [ [ line_invoice_line

			, line_values_line
			
			, line_net_amount_line
		
			, q10( [ check( line_descr = Descr )
				, check( line_item_for_buyer = Item )
				, check( string_to_lower( Descr, DescrL ) )
				, check( string_to_lower( Item, ItemL ) )
				, check( not( q_sys_sub_string( DescrL, _, _, `express` ) ) )
				, check( not( q_sys_sub_string( ItemL, _, _, `express` ) ) )
				
				, check( q_sys_comp_str_eq( line_net_amount, `0` ) )
				, line_type( `ignore` )
			] )
		
		]
		
		, [ force_result( `defect` ), force_sub_result( `missed_line` ) ]
		
	] )
	
	, clear( got_descr )
	
	, q10( [ with( invoice, due_date, Due )
		, line_original_order_date( Due )
	] )

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `:` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  `Pos`, `:`, tab
	  
	, generic_item_cut( [ line_order_line_number, d, tab ] )

	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item_cut( [ line_unit_pre_disc, d, [ q10( `€` ), newline ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  xor( [ generic_item_cut( [ line_item, [ begin, q(dec,4,10), end ], q10( tab ) ] )
	  
		, line_item( `Missing` )
		
	] )
	  
	, q10( generic_item( [ trash, s, [ q10( tab ), check( trash(end) < -260 ) ] ] ) )

	, q10( [ generic_item( [ line_descr, s1, [ tab, check( line_descr(end) < 0 ) ] ] ), set( got_descr ) ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item_cut( [ line_disc, d, tab ] )
	
	, generic_item_cut( [ line_disc2, d, tab ] )

	, generic_item_cut( [ some_num, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_net_amount_line, [
%=======================================================================

	q10( [ generic_item( [ append_descr, s1, [ tab, check( append_descr(end) < 20 ) ] ] )
		, check( append_descr = Append )
		
		, or( [ [ test( got_descr ), append( line_descr(Append), ` `, `` ) ]
		
			, [ peek_fails( test( got_descr ) ), line_descr( Append ) ]
			
		] )
	] )

	, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, [ q10( `€` ), tab ] ] )
	
	, generic_item_cut( [ price_uom, d, tab ] )

	, generic_item_cut( [ line_net_amount, d, [ q10( `€` ), newline ] ] )

] ).