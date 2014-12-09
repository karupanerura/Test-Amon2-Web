requires 'HTTP::Body::Builder::MultiPart';
requires 'HTTP::Body::Builder::UrlEncoded';
requires 'HTTP::Headers';
requires 'HTTP::Message::PSGI';
requires 'HTTP::Request';
requires 'HTTP::Response';
requires 'Scalar::Util';
requires 'URI';
requires 'perl', '5.008001';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Amon2';
    requires 'Amon2::Web';
    requires 'Test::More', '0.98';
    requires 'parent';
};
