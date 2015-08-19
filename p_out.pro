%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - RULES FOR "OUT" PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( p_out_rules, `17 Feb 2013` ).

i_user_field( invoice, egs_buyer_document_identifier, `Identifier used in Document ID construction` ).
i_user_field( invoice, user_document_reference, `Identifier used in results routing` ).

% Why is there a load of EGS stuff in here? Richard D

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER_PARTY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_initialise_rule(  [  set( hilti_live ), trace([`Set HILTI LIVE flag`]) ]) :- i_mail(supplier,`hilti`).
%=======================================================================


%=======================================================================
i_initialise_rule( [
%=======================================================================

      vat_code_1(`S`), vat_rate_1(`20`)

     , vat_code_2(`L`), vat_rate_2(`5`)

 	, vat_code_3(`Z`), vat_rate_3(`0`)

] ).


%=======================================================================
ii_initialise_rule( [
%=======================================================================

	order_number(ON)

	, trace([`order number set from subject`, ON])	
] )
:-
	i_mail(subject, SUBJECT)
	, string_to_lower(SUBJECT, SUBJECT_L)
	, string_string_replace( SUBJECT_L, ` `, ``, SUBJECT_LX )
	, q_sys_sub_string( SUBJECT_LX, I0, _, `ordernumber=`)
	, q_sys_sub_string( SUBJECT_LX, I, _, `=`)
	, sys_calculate( IX, I + 1 )
	, q_sys_sub_string( SUBJECT_LX, IX, _, ON)
.



%=======================================================================
i_rule( egs_get_suppliers_code_for_buyer, [ check( i_user_check( egs_retrieve_buyer, `suppliers_code_for_buyer`, VALUE ) ) , suppliers_code_for_buyer( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_organisation, [ check( i_user_check( egs_retrieve_buyer, `buyer_organisation`, VALUE ) ) , buyer_organisation( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_party, [ check( i_user_check( egs_retrieve_buyer, `buyer_party`, VALUE ) ) , buyer_party( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_address_line, [ check( i_user_check( egs_retrieve_buyer, `buyer_address_line`, VALUE ) ) , buyer_address_line( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_street, [ check( i_user_check( egs_retrieve_buyer, `buyer_street`, VALUE ) ) , buyer_street( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_city, [ check( i_user_check( egs_retrieve_buyer, `buyer_city`, VALUE ) ) , buyer_city( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_state, [ check( i_user_check( egs_retrieve_buyer, `buyer_state`, VALUE ) ) , buyer_state( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_postcode, [ check( i_user_check( egs_retrieve_buyer, `buyer_postcode`, VALUE ) ) , buyer_postcode( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_buyer_contact, [ check( i_user_check( egs_retrieve_buyer, `buyer_contact`, VALUE ) ) , buyer_contact( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_egs_buyer_document_identifier, [ check( i_user_check( egs_retrieve_buyer, `egs_buyer_document_identifier`, VALUE ) )
							, egs_buyer_document_identifier( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_party, [ check( i_user_check( egs_retrieve_supplier, `supplier_party`, VALUE ) ) , supplier_party( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_address_line, [ check( i_user_check( egs_retrieve_supplier, `supplier_address_line`, VALUE ) ) , supplier_address_line( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_street, [ check( i_user_check( egs_retrieve_supplier, `supplier_street`, VALUE ) ) , supplier_street( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_city, [ check( i_user_check( egs_retrieve_supplier, `supplier_city`, VALUE ) ) , supplier_city( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_state, [ check( i_user_check( egs_retrieve_supplier, `supplier_state`, VALUE ) ) , supplier_state( VALUE ) ] ).
%=======================================================================

%=======================================================================
i_rule( egs_get_supplier_postcode, [ check( i_user_check( egs_retrieve_supplier, `supplier_postcode`, VALUE ) ) , supplier_postcode( VALUE ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_check( egs_retrieve_buyer, WHAT, VALUE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	i_mail( to, TO )

	, lookup_cache(`egs`, `to`, TO, WHAT, VALUE )

	, trace( [ `EGS: found`, WHAT, VALUE, `from To Address`, TO ] )

. %end%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Find supplier from: from address; from domain; subject
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_user_check( egs_retrieve_supplier, WHAT, VALUE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	i_mail( from, FROM )

	, lookup_cache(`egs`, `from`, FROM, WHAT, VALUE )

	, trace( [ `EGS: found`, WHAT, VALUE, `from From Address`, FROM ] )

. %end%


%=======================================================================
i_user_check( egs_retrieve_supplier, WHAT, VALUE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	i_mail( from, FROM )

	, q_sys_sub_string(FROM, AT, 1, `@`)

	, sys_calculate(AT1, AT+1)

	, q_sys_sub_string(FROM, AT1, _, DOMAIN)

	, lookup_cache(`egs`, `from`, DOMAIN, WHAT, VALUE )

	, trace( [ `EGS: found`, WHAT, VALUE, `from Domain Address`, FROM ] )

. %end%


%=======================================================================
i_user_check( egs_retrieve_supplier, WHAT, VALUE )
%-----------------------------------------------------------------------
:-
%=======================================================================

	i_mail( subject, SUBJECT )

	, lookup_cache(`egs`, `subject`, SUBJECT, WHAT, VALUE )

	, trace( [ `EGS: found`, WHAT, VALUE, `from Subject`, SUBJECT ] )

. %end%





%=======================================================================
i_rule( gen_get_from_cache_at_end, [
%=======================================================================

%	or( [ egs_get_buyer_postcode, buyer_postcode(`OO00OO` ) ] )

] ).

%=======================================================================
i_final_rule( [
%=======================================================================

	q10([ without(invoice_type), or([ [test(credit_note), invoice_type(`CRN`)], invoice_type(`INV`) ]) ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ASK FOR RULES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_initialise_rule( ask_for_rules ).
%=======================================================================

%=======================================================================
i_rule( ask_for_rules, [
%=======================================================================

	enquire( [ `Supplier (do not set up loops!)` ], Rules, [ secondary, unchained ], RAW, OK )

	, q10( [
		check( i_user_check( gen_same, OK, `answered` ) )

		, supplier( RAW )

		, check( i_user_check( gen_same, supplier, SUPPLIER ) )

		, set( chain, SUPPLIER )
			
		, trace( [ `(enq) Chained to Supplier`, supplier ] )
	] )
] )
:-
	get_rules_file_name( Rules_file_name )

	, sys_string_length( Rules_file_name, L )
	
	, sys_calculate( L4, L - 4 )
	
	, q_sys_sub_string( Rules_file_name, 1, L4, Rules )
.