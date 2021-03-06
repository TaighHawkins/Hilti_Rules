%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - RULES FOR "HILTI QUOTE" PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_quote_rules, `28 November 2014` ).

i_rules_file( `p_hilti_duplicate.pro` ).
i_rules_file( `hilti sales office.pro` ):- i_mail(to,`quotes@gramatica.co.uk`).

i_initialise_rule(  [  set( test_flag ), trace([`Set test flag`]) ]) :- i_mail(to,`quotes@gramatica.co.uk`).

i_initialise_rule( [ set( delay_mins, 10 ), set( chain, `*delay*` ), check( set_imail_data( `delayed`, `10` ) ), trace( [ `DELAYING` ] ) ] )
:-
	i_mail( attachment, Attachment ),
	string_to_lower( Attachment, Attachment_L ),
	not( q_sys_sub_string( Attachment_L, _, _, `body.htm` ) ),
	not( q_imail_data( self, `delayed`, `10` ) ),
	not( q_imail_data( not_self, `body`, `processed` ) ),
	not( q_imail_data( self, `pdf`, `no_delay` ) )
.

i_initialise_rule( [ set( chain, `junk` ), trace( [ `Quote Processed - Junking Attachments` ] ) ] )
:-
	q_imail_data( not_self, `quotation`, `succeeded` )
.