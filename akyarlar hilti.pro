%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Turk  Akyarlar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( akyarlar, `13 July 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	  
	, [q0n(line), get_del_note]
	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_details_2
	
	, get_buyer_contact
	
	, get_delivery_ddi
		
	, get_delivery_contact
	
	, get_buyer_reg
	
	, get_suppliers_code
	
	, get_del_from_loc
	
	%, [q0n(line), get_customer_comments]
	, [q0n(line), get_comment_thing]
	,  [q0n(line), get_comment_thing_2]
	,  [q0n(line), get_comment_thing_3]
	
	
	, [q0n(line), get_buyer_email]
	, [q0n(line), get_delivery_email]
	
	
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

	, [ or([ 
	 [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	   , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`9050`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `10066407` )                      %PROD
	]) ]
	
	, buyer_registration_number(`9`)
	
	%, buyer_location(`WE`)
	%, delivery_from_location(`AP`)
	
	, sender_name( `Akyarlar Yapi` )

%	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER Suppliers Code AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Sipariş`, `Numarası`], 150, order_number, s ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Teslimat`, `Tarihi` ],150,  due_date, date ] )
	  	
] ).

%=======================================================================
i_rule( get_suppliers_code, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Fatura`, `Hesabı`],150,  suppliers_code_for_buyer, s ] )
	
] ).


%=======================================================================
i_rule( get_del_from_loc, [
%=======================================================================	  
	  
	  q(0,25,line), generic_horizontal_details( [ [ `Fatura`, `Hesabı`, tab, dummy(d)], 650,  type_of_supply, s ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_line_rule( get_del_note, [
%======================================================================================================

	`Teslimat`, `hesabı`, tab
	
	

	, or([
	
	
	[read_ahead(`YENİ`), dummy(s),  newline, set(delivery_flag)]
	
	,
	
	[delivery_note_number(d), newline,  set(delivery_flag_2)]
	
	])
	

]).

%======================================================================================================
i_rule( get_delivery_details, [
%======================================================================================================
	
	or([
	
	[test(delivery_flag_2)

	, q0n(line),  generic_horizontal_details( [ [`Teslimat`, `Adresi`],200, delivery_party,s1, tab ] )
	
	, q(0,2,line),  get_delivery_thing( [ delivery_dept])]
	
	,
	
	[test(delivery_flag)

	, q0n(line),  generic_horizontal_details( [ [`Teslimat`, `Adresi`],200, delivery_party,s1, tab ] )]
	
	])
	
]).

%======================================================================================================
i_rule( get_delivery_details_2, [
%======================================================================================================

	test(delivery_flag)
	
	
	, q0n(line), generic_horizontal_details( [ [`ŞANTİYE`],50, delivery_dept,s1 ] )
	
	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	
	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	
	, q(0,2,line),  get_delivery_thing( [ delivery_city])
	
	, q(0,2,line),  get_delivery_thing( [ delivery_postcode])
	
]).


%======================================================================================================
i_line_rule( get_delivery_thing( [ Variable ] ), [ nearest( delivery_dept(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================


%======================================================================================================
i_line_rule( get_comment_thing, [
%======================================================================================================

	or([
	
	[dummy(s), tab, customer_comments(s), tab, `ŞANTİYE`, tab, q0n(anything), newline]
	
	,
	
	[`0`, tab, `ŞANTİYE`, tab, q0n(anything), newline]
	
	,
	
	[customer_comments(s), tab, `ŞANTİYE`, tab, q0n(anything), newline]
	
	])
 
] ).
%======================================================================================================
i_line_rule( get_comment_thing_2, [
%======================================================================================================

	
	or([
	
	[dummy(s), tab,append(customer_comments(s), ` `, ``), tab, `CADDE`, tab, q0n(anything), newline]
	
	,
	
	[`0`, tab, `CADDE`, tab, q0n(anything), newline]
	
	,
	
	[append(customer_comments(s), ` `, ``), tab, `CADDE`, tab, q0n(anything), newline]
	
	])
 
] ).

%======================================================================================================
i_line_rule( get_comment_thing_3, [
%======================================================================================================

	or([
	
	[dummy(s), tab, append(customer_comments(s), ` `, ``), tab, `SOKAK`, `/`, `NO`, tab, q0n(anything), newline]
	
	,
	
	[`0`, tab, `SOKAK`, `/`, `NO`, tab, q0n(anything), newline]
	
	,
	
	[ append(customer_comments(s), ` `, ``), tab, `SOKAK`, `/`, `NO`, tab, q0n(anything), newline]
	
	])
 
] ).


%======================================================================================================
i_rule( get_buyer_reg, [
%======================================================================================================

	q(0,20,line), generic_horizontal_details( [ [read_ahead([ `TR-ADAPTRI`]) ], buyer_registration_number,s1, newline ] )
	
	%, q(0,2,line),  get_buyer_reg_thing( [ buyer_registration_number])
	

]).


%======================================================================================================
i_line_rule( get_buyer_reg_thing( [ Variable ] ), [ nearest( buyer_reg_hook(start), 10, 10 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	q0n(anything), `Eposta`, tab, buyer_email(w), `@`, append(buyer_email(w), `@`, ``), `.`, append(buyer_email(w), `.`, ``), newline
	
	

] ).
%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [ `Satın`, `Alan`, `Kişinin`, `Adı`, `Soyadı`], buyer_contact, s ] )
	
	, get_buyer_ddi

] ).



%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	 q(0,2,line), generic_horizontal_details( [ [ `Telefon`],200,  buyer_ddi, s ] )
	

] ).


%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [`Teslimat`, `Yetkilisi`, `:`], 150, delivery_contact, s ] )
	
] ).

%=======================================================================
i_rule( get_delivery_ddi, [ 
%=======================================================================

	 q(0,200,line), generic_horizontal_details( [ [`Teslimat`, `Yeri`, `Telefon`],150, delivery_ddi, s ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%del email and invoice date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	`Teslimat`, `Yeri`, `Eposta`, `:`, tab, delivery_email(w), `@`, append(delivery_email(w), `@`, ``), `.`, append(delivery_email(w), `.`, ``), tab, `Tarih`, `:`, tab, invoice_date(date), newline
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ at_start, `Ara`, `Toplam` ], 150, total_net, d ] )

		%, q(0, 4, line), generic_horizontal_details( [ [`Toplam` ], 150, total_invoice, d ] )
	
	
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
i_line_rule_cut( line_header_line, [ `Ürün`, `Numarası`, tab, `Ürün`, `Tanımı`, tab, `Min`, `.`, `Sip`, `.`, `Ad`, `.`, tab, `Br`, `.`, tab, `Adet`, tab, `Fiyat`, tab, `Birim`, tab, `Toplam`,  newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	`Ara`, `Toplam`, tab
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	or([
		[line_item(d), tab, line_descr(s), tab, dummy(d), tab, line_quantity_uom_code(w), tab, line_quantity(d), tab, unit(d), dummy(w), tab, dummy(d), tab, line_net_amount(d), dummy(w), newline
	
	,q10( [ with( invoice, due_date, Date ), line_original_order_date( Date ) ] )]
	,
	[line_item(d), tab, line_descr(s), tab, ship(d), tab, line_quantity_uom_code(w), tab, line_quantity(d), tab, unit(s), tab, birim(d), tab, line_net_amount(d), dummy(s), newline
	
	,q10( [ with( invoice, due_date, Date ), line_original_order_date( Date ) ] )]
	
	])
	
	

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).