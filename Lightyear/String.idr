module Lightyear.String

import Lightyear.Core
import Lightyear.Combinators

private
uncons : String -> Maybe (Char, String)
uncons s with (strM s)
  uncons ""             | StrNil       = Nothing
  uncons (strCons x xs) | StrCons x xs = Just (x, xs)

infixl 0 <?->
private
(<?->) : Monad m => ParserT m str a -> String -> ParserT m str a
p <?-> msg = p <??> (Lib, msg)

satisfy : Monad m => (Char -> Bool) -> ParserT m String Char
satisfy = satisfy' (St uncons)

char : Monad m => Char -> ParserT m String ()
char c = skip (satisfy (== c)) <?-> "character '" ++ c2s c ++ "'"

string : Monad m => String -> ParserT m String ()
string s = traverse_ char (unpack s) <?-> "string " ++ show s

space : Monad m => ParserT m String ()
space = skip (many $ satisfy isSpace) <?-> "whitespace"

token : Monad m => String -> ParserT m String ()
token s = skip (string s) <$ space <?-> "token " ++ show s

parens : Monad m => ParserT m String a -> ParserT m String a
parens p = char '(' $> p <$ char ')' <?+> "parenthesized"