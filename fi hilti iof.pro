%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INTELLIGENT ORDER FORM (FINLAND)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( intelligent_order_form_finland, `29 April 2015` ).

i_date_format( _ ).

i_pdf_parameter( max_pages, 1 ).

%=======================================================================
%		User Fields
%=======================================================================

i_user_field( line, zzfminvnr, `ZZFM InvRef` ).
i_user_field( line, zzfmorgref, `ZZFM orgref` ).
i_user_field( line, zzfmcontracttype, `ZZFM contracttype` ).

%=======================================================================
%		Empty Tags
%=======================================================================

i_op_param( xml_empty_tags( Fleet_U ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, fleet_thing( Fleet )
	, sys_string_atom( Fleet, Atom )
	, result( _, LID, Atom, Answer )
	, string_to_upper( Fleet, Fleet_U )
.

fleet_thing( `zzfmcontracttype` ).
fleet_thing( `zzfmorgref` ).
fleet_thing( `zzfminvnr` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list(1, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100 ` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`3300`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, get_buyer_registration_number

	, [ q0n(line), get_type_of_supply ]

	, get_suppliers_code_for_buyer

	, get_delivery_note_number

	, delivery_party_rule

	, get_buyer_contact

	, get_buyer_ddi

	, get_buyer_email

	, get_delivery_contact

	, get_delivery_ddi

	, get_delivery_email

	, get_order_number

	, get_order_date

	, get_due_date

	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_invoice_total

	, [ q0n(line), footer_line ]


] ).


%=======================================================================
i_line_rule_cut( footer_line, [ 
%=======================================================================

	  `Voimassa`, `alkane`

	, q0n(anything)

	, tab, narrative(s1), newline

	, check(narrative(page) = 1)
	
	, trace([`Form Name`, narrative])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER REGISTRATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_registration_number, [ 
%=======================================================================

	  q0n(line), purchase_order_line
	  
	, buyer_registration_number_line
	
	, supplier_line

] ).

%=======================================================================
i_line_rule( purchase_order_line, [ 
%=======================================================================

	  or( [ `Ostotilaus`
	  
		, [ q(0,3,word), `Työkalupalvelutilaus`, set( fleet ) ]
	
	] )

] ).

%=======================================================================
i_line_rule( buyer_registration_number_line, [ 
%=======================================================================

	  generic_item( [ buyer_registration_number, s1, [ newline, check( buyer_registration_number(end) < -250 ) ] ] )

] ).

%=======================================================================
i_line_rule( supplier_line, [ `Toimittaja` ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_type_of_supply, [ 
%=======================================================================

	  q0n(anything)

	,`Toimitustapa`, `:`, tab

	, dummy(s1), tab

	, generic_item( [ type_of_supply, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ at_start, `Sold`, `-`, `to` ], 150, suppliers_code_for_buyer, s1, [ tab, `Toimitustapa` ] ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY PARTY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_party_rule, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ at_start, `Toimitusosoite` ], delivery_party, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `ship`, `-`, `to` ], 150, delivery_note_number, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Tilaajan`, `etu`, `-`, `ja`, `sukunimi` ], 150, buyer_contact, s1, newline ] )

] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ `Tilaajan`, `puhelinnumero` ], 150, buyer_ddi, s1 ] )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	q(0,25,line)
	
	, generic_horizontal_details( [ [ `Tilaajan`, `sähköpostiosoite` ], 150, buyer_email, s1, check( q_sys_sub_string( buyer_email, _, _, `@` ) ) ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ at_start, `Nimi` ], 200, delivery_contact, s1 ] ) 

] ).

%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	q(15,100,line), generic_horizontal_details( [ [ at_start, `Puhelinnumero` ], 200, delivery_ddi, s1 ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	q(0,25,line), generic_horizontal_details( [ [ or( [ [ `Viite`, `/`, `merkki` ], `Kustannuspaikka` ] ), `:` ], 250, order_number, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ or( [ at_start, tab ] ), or( [ `Päivä`, `Date` ] ) ], 200, invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	or( [ [ q(0,25,line), generic_horizontal_details( [ [ `Toimitustapa` ], 250, due_date, date ] ) ]
	
		, [ due_date( Today_string ), trace( [ `Using todays's date`, due_date ] ) ]
		
	] )

] )
:- 
	date_get( today, Today ),
	date_string( Today, 'd/m/y', Today_string )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q(0,25,line), customer_comments_header

	, customer_comments(``), shipping_instructions(``)
	
	, customer_comments_line

	, q(3, 0, customer_comments_line)
	
	, check(i_user_check(gen_same, customer_comments, CC)), shipping_instructions(CC)

] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	q0n(anything), read_ahead( `Lisätiedot` ), special(w)

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	nearest(special(start), 10, 30)

	, qn1( [ append(customer_comments(s), ``, ` `)
	
		, or( [ [ q10( tab ), `C`, `/`, `O` ]

			, [ gen_eof ] 
			
		] ) 
		
	] )



] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_total, [
%=======================================================================

	set( no_total_validation )
	, total_net( `0` )
	, total_invoice( `0` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_line
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Tuotenumero`, tab, `Tuotenimike`, tab ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Välisumma` ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_item, sf, q10( tab ) ] )

	, generic_item_cut( [ line_descr, s1, tab ] )

	, or( [ [ test( fleet )
			, generic_item_cut( [ line_quantity, d, tab ] )
			
			, generic_item_cut( [ zzfminvnr, s1, tab ] )
			, generic_item_cut( [ zzfmorgref, s1, tab ] )
			
			, num(d), tab, `€`, q10( tab )
			
			, count_rule
			, zzfmcontracttype( `ZFPL` )
			, line_quantity_uom_code( `kpl` )
		]
			
		, [ generic_item_cut( [ some_qty, d, q10( tab ) ] )

			, generic_item_cut( [ line_quantity_uom_code, s1, tab ] )
	
			, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
		
			, `€`, q0n(anything), `€`, q10( tab )
		]
	] )
	
	, or( [ `-`
		, [ set( regexp_cross_word_boundaries ), num(d), clear( regexp_cross_word_boundaries ) ]
	] ), newline
		
	, with( invoice, due_date, DATE )
	, line_original_order_date( DATE )

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).
